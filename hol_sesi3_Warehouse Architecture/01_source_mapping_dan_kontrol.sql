-- READ ONLY. Pilih satu database sumber yang tersedia.
-- Ganti USE menjadi lab_asuransi_konseptual atau lab_asuransi_sesi2_sumber jika diperlukan.
USE lab_asuransi_sesi3_sumber;
SHOW TABLES;
DESCRIBE polis;
DESCRIBE kontribusi;
DESCRIBE klaim;

-- S1 Lima entitas, 23 kolom. Tidak ada kolom Channel pada fixture.
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- S2 Pemetaan sumber Contribution: satu baris transaksi, bukan satu polis-bulan.
SELECT k.kontribusi_id,k.polis_id,p.nomor_polis,p.produk_id,pr.nama_produk,
       p.peserta_id,k.tanggal_kontribusi,k.jumlah_kontribusi,k.status_kontribusi
FROM kontribusi k JOIN polis p ON p.polis_id=k.polis_id
JOIN produk pr ON pr.produk_id=p.produk_id
ORDER BY k.kontribusi_id LIMIT 8;

-- S3 Pemetaan sumber Claims: dua peran tanggal yang berbeda.
SELECT k.klaim_id,k.polis_id,p.produk_id,p.peserta_id,
       k.tanggal_pengajuan,k.tanggal_bayar,k.nilai_pengajuan,k.nilai_bayar,k.status_klaim
FROM klaim k JOIN polis p ON p.polis_id=k.polis_id
ORDER BY k.klaim_id;

-- S4 Kontrol mart Contribution: 50 baris LUNAS dan Rp7.450.000.
SELECT COUNT(*) AS jumlah_transaksi,SUM(jumlah_kontribusi) AS total_rupiah
FROM kontribusi WHERE status_kontribusi='LUNAS'
AND tanggal_kontribusi>='2026-01-01' AND tanggal_kontribusi<'2026-04-01';

-- S5 Kontrol mart Claims: 5 klaim dibayar dan Rp9.700.000.
SELECT COUNT(*) AS jumlah_klaim,SUM(nilai_bayar) AS total_rupiah
FROM klaim WHERE status_klaim='DIBAYAR'
AND tanggal_bayar>='2026-01-01' AND tanggal_bayar<'2026-04-01';

-- S6 Kontrol bulanan: gunakan peran tanggal sesuai KPI.
SELECT pr.nama_produk,DATE_FORMAT(k.tanggal_kontribusi,'%Y-%m') AS bulan,
       SUM(k.jumlah_kontribusi) AS kontribusi_lunas
FROM kontribusi k JOIN polis p ON p.polis_id=k.polis_id
JOIN produk pr ON pr.produk_id=p.produk_id
WHERE k.status_kontribusi='LUNAS'
AND k.tanggal_kontribusi>='2026-01-01' AND k.tanggal_kontribusi<'2026-04-01'
GROUP BY pr.nama_produk,DATE_FORMAT(k.tanggal_kontribusi,'%Y-%m')
ORDER BY pr.nama_produk,bulan;

SELECT pr.nama_produk,DATE_FORMAT(k.tanggal_bayar,'%Y-%m') AS bulan,
       SUM(k.nilai_bayar) AS klaim_dibayar
FROM klaim k JOIN polis p ON p.polis_id=k.polis_id
JOIN produk pr ON pr.produk_id=p.produk_id
WHERE k.status_klaim='DIBAYAR'
AND k.tanggal_bayar>='2026-01-01' AND k.tanggal_bayar<'2026-04-01'
GROUP BY pr.nama_produk,DATE_FORMAT(k.tanggal_bayar,'%Y-%m')
ORDER BY pr.nama_produk,bulan;

-- S7 Risiko fan-out: 6 baris dari 3 kontribusi x 2 klaim pada polis 1.
SELECT COUNT(*) AS baris_join FROM kontribusi k
JOIN klaim c ON c.polis_id=k.polis_id WHERE k.polis_id=1;
-- Rancangan warehouse tidak boleh menjumlahkan nilai dari join ini.
