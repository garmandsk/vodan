-- Nonaktifkan produk setelah transaksi membuat stoknya habis.
CREATE OR REPLACE FUNCTION update_sold_stock()
RETURNS TRIGGER AS $$
DECLARE
    item jsonb;
    target_id text;
    target_qty integer;
BEGIN
    IF NEW.items IS NOT NULL THEN
        FOR item IN SELECT * FROM jsonb_array_elements(NEW.items)
        LOOP
            target_id := item->>'id';
            target_qty := COALESCE((item->>'qty')::integer, 0);

            UPDATE products
            SET sold = COALESCE(sold, 0) + target_qty,
                is_active = CASE
                    WHEN COALESCE(sold, 0) + target_qty >= COALESCE(stock, 0)
                    THEN false
                    ELSE is_active
                END
            WHERE workspace_id = NEW.workspace_id
              AND id = target_id;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Sinkronkan data lama yang sudah habis sebelum migrasi ini diterapkan.
UPDATE products
SET is_active = false
WHERE COALESCE(sold, 0) >= COALESCE(stock, 0);
