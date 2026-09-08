CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

REVOKE SELECT (ai_keys), INSERT (ai_keys), UPDATE (ai_keys)
ON TABLE public.workspaces
FROM anon, authenticated;

DO $$
DECLARE
  v_workspace RECORD;
  v_item JSONB;
  v_keys JSONB;
  v_key TEXT;
BEGIN
  FOR v_workspace IN
    SELECT id, COALESCE(ai_keys, '[]'::JSONB) AS ai_keys
    FROM public.workspaces
  LOOP
    IF jsonb_typeof(v_workspace.ai_keys) <> 'array' THEN
      CONTINUE;
    END IF;

    v_keys := '[]'::JSONB;
    FOR v_item IN SELECT value FROM jsonb_array_elements(v_workspace.ai_keys)
    LOOP
      v_key := NULLIF(v_item->>'key', '');
      IF v_key IS NULL THEN
        CONTINUE;
      END IF;

      v_keys := v_keys || jsonb_build_array(jsonb_build_object(
        'provider', v_item->>'provider',
        'key', encode(
          extensions.pgp_sym_encrypt(v_key, 'SERVER_SECRET'),
          'base64'
        )
      ));
    END LOOP;

    UPDATE public.workspaces
    SET ai_keys = v_keys,
        updated_at = now()
    WHERE id = v_workspace.id;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_masked_api_keys(p_workspace_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_keys JSONB;
  v_result JSONB := '[]'::JSONB;
  v_item JSONB;
  v_plaintext TEXT;
  v_provider TEXT;
  v_ciphertext TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.workspaces
    WHERE id = p_workspace_id
      AND owner_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Workspace access denied';
  END IF;

  SELECT COALESCE(ai_keys, '[]'::JSONB)
  INTO v_keys
  FROM public.workspaces
  WHERE id = p_workspace_id;

  IF jsonb_typeof(v_keys) <> 'array' THEN
    RETURN '[]'::JSONB;
  END IF;

  FOR v_item IN SELECT value FROM jsonb_array_elements(v_keys)
  LOOP
    v_provider := NULLIF(v_item->>'provider', '');
    v_ciphertext := NULLIF(v_item->>'key', '');
    IF v_provider IS NULL OR v_ciphertext IS NULL THEN
      CONTINUE;
    END IF;

    BEGIN
      v_plaintext := extensions.pgp_sym_decrypt(
        decode(v_ciphertext, 'base64'),
        'SERVER_SECRET'
      );
    EXCEPTION WHEN OTHERS THEN
      CONTINUE;
    END;

    v_result := v_result || jsonb_build_array(jsonb_build_object(
      'provider', v_provider,
      'key', '***' || right(v_plaintext, 4)
    ));
  END LOOP;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.sync_workspace_api_keys(
  p_workspace_id UUID,
  p_keys JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payload JSONB := COALESCE(p_keys, '[]'::JSONB);
  v_existing JSONB;
  v_result JSONB := '[]'::JSONB;
  v_item JSONB;
  v_provider TEXT;
  v_key TEXT;
  v_existing_key TEXT;
  v_encrypted_key TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.workspaces
    WHERE id = p_workspace_id
      AND owner_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Workspace access denied';
  END IF;

  IF jsonb_typeof(v_payload) <> 'array' THEN
    RAISE EXCEPTION 'p_keys must be a JSON array';
  END IF;

  SELECT COALESCE(ai_keys, '[]'::JSONB)
  INTO v_existing
  FROM public.workspaces
  WHERE id = p_workspace_id
  FOR UPDATE;

  FOR v_item IN SELECT value FROM jsonb_array_elements(v_payload)
  LOOP
    v_provider := NULLIF(btrim(v_item->>'provider'), '');
    v_key := NULLIF(v_item->>'key', '');
    IF v_provider IS NULL OR v_key IS NULL THEN
      CONTINUE;
    END IF;

    IF left(v_key, 3) = '***' THEN
      SELECT item->>'key'
      INTO v_existing_key
      FROM jsonb_array_elements(v_existing) AS item
      WHERE item->>'provider' = v_provider
      LIMIT 1;

      IF v_existing_key IS NULL THEN
        CONTINUE;
      END IF;

      v_encrypted_key := v_existing_key;
    ELSE
      v_encrypted_key := encode(
        extensions.pgp_sym_encrypt(v_key, 'SERVER_SECRET'),
        'base64'
      );
    END IF;

    v_result := v_result || jsonb_build_array(jsonb_build_object(
      'provider', v_provider,
      'key', v_encrypted_key
    ));
  END LOOP;

  UPDATE public.workspaces
  SET ai_keys = v_result,
      updated_at = now()
  WHERE id = p_workspace_id;

  RETURN public.get_masked_api_keys(p_workspace_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.get_decrypted_api_key(
  p_workspace_id UUID,
  p_provider TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ciphertext TEXT;
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'Service role required';
  END IF;

  SELECT item->>'key'
  INTO v_ciphertext
  FROM public.workspaces w,
       LATERAL jsonb_array_elements(COALESCE(w.ai_keys, '[]'::JSONB)) AS item
  WHERE w.id = p_workspace_id
    AND item->>'provider' = p_provider
  LIMIT 1;

  IF v_ciphertext IS NULL OR v_ciphertext = '' THEN
    RETURN NULL;
  END IF;

  RETURN extensions.pgp_sym_decrypt(
    decode(v_ciphertext, 'base64'),
    'SERVER_SECRET'
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_masked_api_keys(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_masked_api_keys(UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.sync_workspace_api_keys(UUID, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sync_workspace_api_keys(UUID, JSONB) TO authenticated;

REVOKE ALL ON FUNCTION public.get_decrypted_api_key(UUID, TEXT) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_decrypted_api_key(UUID, TEXT) TO service_role;