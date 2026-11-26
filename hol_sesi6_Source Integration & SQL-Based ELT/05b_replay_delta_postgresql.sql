-- PostgreSQL: replay empat perubahan setelah 05a pada sumber MariaDB.
-- VALUES di bawah adalah delta transport yang disediakan untuk menghemat waktu kelas.
-- Ini bukan bukti transfer otomatis atau CDC. Tidak ada updated_at pada sumber.
-- Rerun file ini aman; tidak ada INSERT append tanpa conflict handling.
BEGIN;
INSERT INTO s6_staging.contribution VALUES (2,1,'2026-02-10',110000,'LUNAS'),
 (10,2,'2026-03-20',125000,'LUNAS')
ON CONFLICT(event_id) DO UPDATE SET amount=EXCLUDED.amount;
INSERT INTO s6_staging.claim VALUES
 (2,1,'2026-02-10','2026-03-05',950000,'DIBAYAR'),
 (6,2,'2026-03-15','2026-03-25',400000,'DIBAYAR')
ON CONFLICT(event_id) DO UPDATE SET paid_amount=EXCLUDED.paid_amount;
-- Expected counts berasal dari source sesudah 05a, bukan dihitung dari staging.
UPDATE s6_staging.manifest SET expected_rows=10 WHERE table_name='contribution';
UPDATE s6_staging.manifest SET expected_rows=6 WHERE table_name='claim';
COMMIT;
-- Lanjut: ulang 03 -> 04 yang telah terisi -> 06. Ulang 03+04 SEKALI LAGI.
-- Hasil wajib tetap 7 / 885000 dan 4 / 5650000, tanpa fact duplikat.
