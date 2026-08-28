-- 1. Buat fungsi logika penambahan stok terjual
CREATE OR REPLACE FUNCTION update_sold_stock()
RETURNS TRIGGER AS $$
DECLARE
    item jsonb;
BEGIN
    -- Lakukan perulangan untuk setiap barang di dalam array JSON 'items'
    FOR item IN SELECT * FROM jsonb_array_elements(NEW.items)
    LOOP
        -- Update tabel products: tambahkan nilai 'sold' dengan 'qty' dari JSON
        -- Pastikan mencocokkan workspace_id dan id barang (Composite Key)
        UPDATE products
        SET sold = COALESCE(sold, 0) + (item->>'qty')::integer
        WHERE workspace_id = NEW.workspace_id 
          AND id = item->>'id';
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Pasang pelatuk (Trigger) ke tabel transaction_log
CREATE TRIGGER after_transaction_insert
AFTER INSERT ON transaction_log
FOR EACH ROW
EXECUTE FUNCTION update_sold_stock();