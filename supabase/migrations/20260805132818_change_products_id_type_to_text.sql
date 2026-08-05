-- 1. Hapus status Primary Key lama terlebih dahulu
ALTER TABLE products DROP CONSTRAINT products_pkey;

-- 2. Ubah tipe data kolom 'id' dari uuid menjadi text
ALTER TABLE products ALTER COLUMN id TYPE text;
ALTER TABLE products ALTER COLUMN id DROP DEFAULT;

-- 3. Pasang Primary Key baru (Composite Key: workspace_id + id)
ALTER TABLE products ADD PRIMARY KEY (workspace_id, id);