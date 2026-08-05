-- 1. Hapus dulu trigger dan fungsi lama jika sempat tersangkut
DROP TRIGGER IF EXISTS after_transaction_insert ON transaction_log;
DROP FUNCTION IF EXISTS update_sold_stock();

-- 2. Buat ulang fungsi logika penambahan stok terjual yang lebih aman
CREATE OR REPLACE FUNCTION update_sold_stock()
RETURNS TRIGGER AS $$
DECLARE
    item jsonb;
    target_id text;
    target_qty integer;
BEGIN
    -- Periksa apakah items ada dan berbentuk array
    IF NEW.items IS NOT NULL THEN
        FOR item IN SELECT * FROM jsonb_array_elements(NEW.items)
        LOOP
            target_id := item->>'id';
            target_qty := COALESCE((item->>'qty')::integer, 0);

            -- Update tabel products: tambahkan nilai 'sold' berdasarkan workspace_id dan id barang
            UPDATE products
            SET sold = COALESCE(sold, 0) + target_qty
            WHERE workspace_id = NEW.workspace_id 
              AND id = target_id;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Pasang kembali pelatuk (Trigger) ke tabel transaction_log
CREATE TRIGGER after_transaction_insert
AFTER INSERT ON transaction_log
FOR EACH ROW
EXECUTE FUNCTION update_sold_stock();