-- Buat indeks setelah tabel dan data siap. Jalankan sekali.
CREATE INDEX idx_contribution_date_product
 ON mart.fact_contribution_receipt(contribution_date_key,product_key);
-- TODO D: indeks gabungan payment_date_key,product_key pada fact_claim_payment.
-- TODO E: indeks policy_key pada masing-masing fact (dua indeks).
-- PK/UNIQUE sudah mempunyai indeks; FK tidak otomatis membuat indeks pada fact.
ANALYZE mart.fact_contribution_receipt;
ANALYZE mart.fact_claim_payment;
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.nama_produk,SUM(f.jumlah_kontribusi)
FROM mart.fact_contribution_receipt f
JOIN mart.dim_product p ON p.product_key=f.product_key
WHERE f.contribution_date_key BETWEEN 20260101 AND 20260331
GROUP BY p.nama_produk;
-- Seq Scan dapat wajar pada 6 baris. Indeks tidak menjamin lebih cepat.
-- Catat scan, join, estimated/actual rows. Jangan memaksa enable_seqscan=off.
