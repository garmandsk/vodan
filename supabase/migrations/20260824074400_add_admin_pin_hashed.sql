CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

CREATE OR REPLACE FUNCTION hash_workspace_pin()
RETURNS TRIGGER AS $$
BEGIN
  -- Cek apakah ada PIN yang dimasukkan, dan pastikan nilainya berubah/baru
  IF NEW.admin_pin IS NOT NULL AND (TG_OP = 'INSERT' OR NEW.admin_pin IS DISTINCT FROM OLD.admin_pin) THEN
    -- Ubah teks asli menjadi hash bcrypt
    NEW.admin_pin := extensions.crypt(NEW.admin_pin, extensions.gen_salt('bf'));
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Pasang fungsi tersebut sebagai Trigger di tabel workspaces
CREATE TRIGGER hash_pin_before_insert_update
BEFORE INSERT OR UPDATE OF admin_pin
ON workspaces
FOR EACH ROW
EXECUTE FUNCTION hash_workspace_pin();