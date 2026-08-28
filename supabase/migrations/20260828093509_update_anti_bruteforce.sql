CREATE OR REPLACE FUNCTION verify_workspace(
  p_workspace_id UUID, 
  p_user_id UUID,
  p_device_id UUID, 
  p_input_pin TEXT
) RETURNS JSON AS $$
DECLARE
  v_owner_id UUID;
  v_actual_pin TEXT;
BEGIN
  SELECT owner_id INTO v_owner_id
  FROM workspaces WHERE id = p_workspace_id;

  IF NOT FOUND THEN
    RETURN json_build_object('status', 'error', 'message', 'Lapak tidak ditemukan');
  END IF;

  IF p_user_id != v_owner_id THEN
    RETURN json_build_object(
      'status', 'unauthorized', 
      'message', 'Akses ditolak. Hanya Owner yang dapat melakukan verifikasi.'
    );
  END IF;

  SELECT admin_pin INTO v_actual_pin
  FROM workspaces WHERE id = p_workspace_id;

  IF v_actual_pin = extensions.crypt(p_input_pin, v_actual_pin) THEN
    RETURN json_build_object('status', 'success', 'message', 'PIN Valid');
  ELSE
    RETURN json_build_object('status', 'failed', 'message', 'PIN salah');
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;