-- 1. Aktifkan ekstensi pgcrypto untuk standar hashing industri
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Buat Fungsi RPC untuk validasi login
CREATE OR REPLACE FUNCTION verify_workspace(
  p_workspace_id UUID,
  p_pin TEXT
) RETURNS BOOLEAN AS $$ 
DECLARE
  stored_hash TEXT;
BEGIN
  SELECT admin_pin INTO stored_hash
  FROM workspaces WHERE id = p_workspace_id;

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  IF stored_hash = extensions.crypt(p_pin, stored_hash) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;