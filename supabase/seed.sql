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
VALUES
  ('00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'owner1@example.com',
  extensions.crypt('password123', extensions.gen_salt('bf')), -- Password ter-hash
  now(),
  '{"name": "Owner Ganteng"}',
  'authenticated',
  'authenticated'),
  ('00000000-0000-0000-0000-000000000003',
  '00000000-0000-0000-0000-000000000002',
  'owner2@example.com',
  extensions.crypt('password456', extensions.gen_salt('bf')), -- Password ter-hash
  now(),
  '{"name": "Owner Amazing"}',
  'authenticated',
  'authenticated');

-- (Opsional) Jika trigger public.users Anda sudah jalan, data di public.users akan otomatis terisi.
-- Tapi untuk amannya, Anda juga bisa langsung insert workspace untuk user di atas:
INSERT INTO public.workspaces (
  id, 
  owner_id, 
  name, 
  admin_pin, 
  ai_keys
) 
VALUES 
  ('c0a80121-7922-4988-8422-83492384923a', 
  '00000000-0000-0000-0000-000000000001', 
  'Lapak Cabang Medan', 
  extensions.crypt('123456', extensions.gen_salt('bf')), 
  '[{"key": "aikey", "provider": "gemini"}]'::jsonb),
  ('c0a80121-7922-4988-8422-83492384923b', 
  '00000000-0000-0000-0000-000000000003', 
  'Danus Imilkom', 
  extensions.crypt('654321', extensions.gen_salt('bf')), 
  '[{"key": "aikey", "provider": "gemini"}]'::jsonb);

INSERT INTO public.products (
  id,
  workspace_id, 
  name, 
  category, 
  nlp_alias, 
  price, 
  stock
) 
VALUES 
  ('BRG-001',
  'c0a80121-7922-4988-8422-83492384923a', 
  'Kopi Susu Gula Aren', 
  'Minuman', 
  ARRAY['kopi susu', 'kopi'], 
  18000, 
  100),
  ('BRG-002',
  'c0a80121-7922-4988-8422-83492384923a', 
  'Ayam Geprek Sambal Matah', 
  'Makanan', 
  ARRAY['Ayam Geprek', 'Geprek'], 
  15000, 
  50),
  ('BRG-001',
  'c0a80121-7922-4988-8422-83492384923b', 
  'Teh sisri', 
  'Minuman', 
  ARRAY['Teh sisri', 'teh sachet'], 
  3000, 
  100),
  ('BRG-002',
  'c0a80121-7922-4988-8422-83492384923b', 
  'Ayam Penyet Jakarta', 
  'Makanan', 
  ARRAY['Ayam Penyet', 'Penyet'], 
  15000, 
  50);

INSERT INTO public.transaction_log (
  workspace_id,
  transaction_time,
  items,
  total_price,
  discount,
  currency,
  payment_method,
  status,
  cashier_name
) VALUES 
  ('c0a80121-7922-4988-8422-83492384923a',
  '2026-08-08 20:45:00+00',                                
  '[
    {
      "id": "BRG-001", 
      "name": "Kopi susu", 
      "qty": 4, 
      "price": 18000.00, 
      "subtotal": 72000.00
    },
    {
      "id": "BRG-002", 
      "name": "Ayam geprek", 
      "qty": 4, 
      "price": 15000.00, 
      "subtotal": 60000.00
    }
  ]'::jsonb,                                               
  132000.00,                                                 
  0,                                                       
  'IDR',                                                   
  'qris',                                                  
  'paid',                                                  
  'Kasir-HP-01'),
  ('c0a80121-7922-4988-8422-83492384923a',
  '2026-08-09 20:45:00+00',                                
  '[
    {
      "id": "BRG-001", 
      "name": "Kopi susu", 
      "qty": 4, 
      "price": 18000.00, 
      "subtotal": 72000.00
    },
    {
      "id": "BRG-002", 
      "name": "Ayam geprek", 
      "qty": 4, 
      "price": 15000.00, 
      "subtotal": 60000.00
    }
  ]'::jsonb,                                               
  132000.00,                                                 
  0,                                                       
  'IDR',                                                   
  'qris',                                                  
  'paid',                                                  
  'Kasir-HP-02'),
  ('c0a80121-7922-4988-8422-83492384923b',
  '2026-08-08 20:45:00+00',                                
  '[
    {
      "id": "BRG-001", 
      "name": "Teh sisri", 
      "qty": 4, 
      "price": 3000.00, 
      "subtotal": 12000.00
    },
    {
      "id": "BRG-002", 
      "name": "Ayam penyet", 
      "qty": 4, 
      "price": 15000.00, 
      "subtotal": 60000.00
    }
  ]'::jsonb,                                               
  72000.00,                                                 
  0,                                                       
  'IDR',                                                   
  'qris',                                                  
  'paid',                                                  
  'Kasir-HP-10'),
  ('c0a80121-7922-4988-8422-83492384923b',
  '2026-08-10 20:45:00+00',                                
  '[
    {
      "id": "BRG-001", 
      "name": "Teh sisri", 
      "qty": 4, 
      "price": 3000.00, 
      "subtotal": 12000.00
    },
    {
      "id": "BRG-002", 
      "name": "Ayam penyet", 
      "qty": 4, 
      "price": 15000.00, 
      "subtotal": 60000.00
    }
  ]'::jsonb,                                               
  72000.00,                                                 
  0,                                                       
  'IDR',                                                   
  'qris',                                                  
  'paid',                                                  
  'Kasir-HP-11');