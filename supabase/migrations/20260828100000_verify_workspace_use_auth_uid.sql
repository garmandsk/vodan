DROP FUNCTION IF EXISTS verify_workspace(UUID, UUID, UUID, TEXT);

CREATE OR REPLACE FUNCTION verify_workspace(
  p_workspace_id UUID,
  p_device_id UUID,
  p_input_pin TEXT
) RETURNS JSON AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_owner_id UUID;
  v_actual_pin TEXT;
BEGIN
  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'status', 'unauthorized',
      'message', 'Sesi Supabase tidak valid atau sudah habis.'
    );
  END IF;

  SELECT owner_id, admin_pin
  INTO v_owner_id, v_actual_pin
  FROM workspaces
  WHERE id = p_workspace_id;

  IF NOT FOUND THEN
    RETURN json_build_object('status', 'error', 'message', 'Lapak tidak ditemukan');
  END IF;

  IF v_user_id != v_owner_id THEN
    RETURN json_build_object(
      'status', 'unauthorized',
      'message', 'Akses ditolak. Hanya Owner yang dapat melakukan verifikasi.'
    );
  END IF;

  IF v_actual_pin = extensions.crypt(p_input_pin, v_actual_pin) THEN
    RETURN json_build_object('status', 'success', 'message', 'PIN Valid');
  END IF;

  RETURN json_build_object('status', 'failed', 'message', 'PIN salah');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;