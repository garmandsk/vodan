-- Memasukkan data tiruan untuk kategori atau produk awal
-- Masukkan data user yang tertinggal secara manual ke public.users
-- 1. Masukkan data dummy ke auth.users (Supabase Local mengizinkan insert manual ke auth.users untuk development)
INSERT INTO auth.users (
  id, 
  instance_id, 
  email, 
  encrypted_password, 
  email_confirmed_at, 
  raw_user_meta_data,
  role, 
  aud
)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'owner@example.com',
  extensions.crypt('password123', extensions.gen_salt('bf')), -- Password ter-hash
  now(),
  '{"name": "Owner Ganteng"}',
  'authenticated',
  'authenticated'
);

-- (Opsional) Jika trigger public.users Anda sudah jalan, data di public.users akan otomatis terisi.
-- Tapi untuk amannya, Anda juga bisa langsung insert workspace untuk user di atas:
INSERT INTO public.workspaces (id, name, owner_id) 
VALUES ('c0a80121-7922-4988-8422-83492384923a', 'Lapak Cabang Medan', '00000000-0000-0000-0000-000000000001');

-- INSERT INTO workspaces (id, name, owner_id) 
-- VALUES ('c0a80121-7922-4988-8422-83492384923a', 'Lapak Cabang Medan', 'fcf779be-cec2-4ab0-bd08-ca4c05328bad');su

INSERT INTO products (workspace_id, name, price, stock) 
VALUES 
  ('c0a80121-7922-4988-8422-83492384923a', 'Kopi Susu Gula Aren', 18000, 100),
  ('c0a80121-7922-4988-8422-83492384923a', 'Ayam Geprek Sambal Matah', 25000, 50);