-- AKTIVITAS 4. Read only. Jalankan setelah 01-04 selesai.
-- V1: 2 staging + 4 dimensi + 2 fact = 8 tabel dasar.
SELECT table_schema,table_name FROM information_schema.tables
WHERE table_schema IN ('staging','mart') AND table_type='BASE TABLE'
ORDER BY table_schema,table_name;
SELECT table_name,constraint_type,COUNT(*) AS jumlah
FROM information_schema.table_constraints WHERE table_schema='mart'
GROUP BY table_name,constraint_type ORDER BY table_name,constraint_type;
SELECT tablename,indexname,indexdef FROM pg_indexes
WHERE schemaname='mart' ORDER BY tablename,indexname;

-- V2: kontrol sampel. Hasil 6 / 750000 dan 3 / 5200000.
SELECT COUNT(*) AS baris,SUM(jumlah_kontribusi) AS rupiah,
 SUM(transaction_count) AS transaksi FROM mart.fact_contribution_receipt;
SELECT COUNT(*) AS baris,SUM(nilai_bayar) AS rupiah,
 SUM(paid_claim_count) AS klaim FROM mart.fact_claim_payment;
-- V3: keunikan grain. Kedua query harus kosong, meskipun PK fact berbeda.
SELECT source_system,kontribusi_id,COUNT(*) FROM mart.fact_contribution_receipt
GROUP BY source_system,kontribusi_id HAVING COUNT(*)>1;
SELECT source_system,klaim_id,COUNT(*) FROM mart.fact_claim_payment
GROUP BY source_system,klaim_id HAVING COUNT(*)>1;

-- V4 fact_contribution_receipt: nol orphan pada empat FK.
SELECT COUNT(*) AS orphan_rows FROM mart.fact_contribution_receipt f
LEFT JOIN mart.dim_date d ON d.date_key=f.contribution_date_key
LEFT JOIN mart.dim_product p ON p.product_key=f.product_key
LEFT JOIN mart.dim_policy po ON po.policy_key=f.policy_key
LEFT JOIN mart.dim_participant pe ON pe.participant_key=f.participant_key
WHERE d.date_key IS NULL OR p.product_key IS NULL
 OR po.policy_key IS NULL OR pe.participant_key IS NULL;

-- V4 fact_claim_payment: nol orphan pada empat FK.
SELECT COUNT(*) AS orphan_rows FROM mart.fact_claim_payment f
LEFT JOIN mart.dim_date d ON d.date_key=f.payment_date_key
LEFT JOIN mart.dim_product p ON p.product_key=f.product_key
LEFT JOIN mart.dim_policy po ON po.policy_key=f.policy_key
LEFT JOIN mart.dim_participant pe ON pe.participant_key=f.participant_key
WHERE d.date_key IS NULL OR p.product_key IS NULL
 OR po.policy_key IS NULL OR pe.participant_key IS NULL;

-- V5 JOIN analitik fact_contribution_receipt: bandingkan jumlah baris dengan V2.
SELECT COUNT(*) AS joined_rows,SUM(f.jumlah_kontribusi) AS total_rupiah
FROM mart.fact_contribution_receipt f
JOIN mart.dim_date d ON d.date_key=f.contribution_date_key
JOIN mart.dim_product p ON p.product_key=f.product_key
JOIN mart.dim_policy po ON po.policy_key=f.policy_key
JOIN mart.dim_participant pe ON pe.participant_key=f.participant_key;
-- V6 agregasi per produk per bulan menggunakan peran tanggal yang benar.
SELECT d.year_number,d.month_number,p.nama_produk,
 SUM(f.jumlah_kontribusi) AS rupiah,SUM(f.transaction_count) AS jumlah
FROM mart.fact_contribution_receipt f
JOIN mart.dim_date d ON d.date_key=f.contribution_date_key
JOIN mart.dim_product p ON p.product_key=f.product_key
GROUP BY d.year_number,d.month_number,p.nama_produk
ORDER BY d.year_number,d.month_number,p.nama_produk;

-- V5 JOIN analitik fact_claim_payment: bandingkan jumlah baris dengan V2.
SELECT COUNT(*) AS joined_rows,SUM(f.nilai_bayar) AS total_rupiah
FROM mart.fact_claim_payment f
JOIN mart.dim_date d ON d.date_key=f.payment_date_key
JOIN mart.dim_product p ON p.product_key=f.product_key
JOIN mart.dim_policy po ON po.policy_key=f.policy_key
JOIN mart.dim_participant pe ON pe.participant_key=f.participant_key;
-- V6 agregasi per produk per bulan menggunakan peran tanggal yang benar.
SELECT d.year_number,d.month_number,p.nama_produk,
 SUM(f.nilai_bayar) AS rupiah,SUM(f.paid_claim_count) AS jumlah
FROM mart.fact_claim_payment f
JOIN mart.dim_date d ON d.date_key=f.payment_date_key
JOIN mart.dim_product p ON p.product_key=f.product_key
GROUP BY d.year_number,d.month_number,p.nama_produk
ORDER BY d.year_number,d.month_number,p.nama_produk;

-- V7: laporkan versi dimensi tumpang tindih; harus kosong pada fixture.
SELECT a.peserta_id,a.participant_key,b.participant_key
FROM mart.dim_participant a JOIN mart.dim_participant b
 ON a.source_system=b.source_system AND a.peserta_id=b.peserta_id
 AND a.participant_key<b.participant_key
 AND (b.valid_to IS NULL OR a.valid_from<b.valid_to)
 AND (a.valid_to IS NULL OR b.valid_from<a.valid_to);
-- Constraint metadata belum mencegah semua overlap historis; query ini diperlukan.
-- Jangan join kedua fact langsung lewat polis sebelum agregasi: berisiko fanout.
