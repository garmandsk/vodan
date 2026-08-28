-- 1. Hapus status Primary Key lama (secara default Supabase menamainya tabel_pkey)
ALTER TABLE products DROP CONSTRAINT pk_products_catalogue;

-- 2. Buat Primary Key baru gabungan dari 'workspace_id' dan 'id'
ALTER TABLE products ADD PRIMARY KEY (workspace_id, id);