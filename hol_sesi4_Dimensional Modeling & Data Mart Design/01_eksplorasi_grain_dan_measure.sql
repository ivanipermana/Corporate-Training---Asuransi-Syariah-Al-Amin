-- READ ONLY. Sesuaikan USE jika menggunakan sumber Sesi 1/2/3.
USE lab_asuransi_sesi4_sumber;
SHOW TABLES;
DESCRIBE kontribusi;
DESCRIBE klaim;
DESCRIBE polis;
DESCRIBE peserta;

-- E1 Grain natural transaksi: jumlah baris sumber per polis, semua status.
SELECT polis_id,COUNT(*) AS contribution_count
FROM kontribusi GROUP BY polis_id ORDER BY contribution_count DESC,polis_id LIMIT 10;

-- E2 Profil seluruh transaksi, bukan hanya transaksi yang masuk KPI.
SELECT COUNT(*) AS transaction_count,SUM(jumlah_kontribusi) AS total_contribution
FROM kontribusi;
SELECT status_kontribusi,COUNT(*) AS jumlah,SUM(jumlah_kontribusi) AS nilai
FROM kontribusi GROUP BY status_kontribusi;
SELECT status_klaim,COUNT(*) AS jumlah,SUM(nilai_bayar) AS nilai_bayar
FROM klaim GROUP BY status_klaim;

-- E3 Satu polis punya transaksi dan klaim terpisah. Tinjau contoh polis 1.
SELECT * FROM kontribusi WHERE polis_id=1 ORDER BY kontribusi_id;
SELECT * FROM klaim WHERE polis_id=1 ORDER BY klaim_id;
SELECT COUNT(*) AS baris_join FROM kontribusi k JOIN klaim c ON c.polis_id=k.polis_id
WHERE k.polis_id=1;

-- E4 Telusuri kandidat dimensi dari fakta ke sumber induk.
SELECT k.kontribusi_id,k.polis_id,p.nomor_polis,p.produk_id,pr.nama_produk,
       p.peserta_id,pes.nama_peserta,pes.kota,k.tanggal_kontribusi,k.jumlah_kontribusi
FROM kontribusi k JOIN polis p ON p.polis_id=k.polis_id
JOIN produk pr ON pr.produk_id=p.produk_id
JOIN peserta pes ON pes.peserta_id=p.peserta_id
ORDER BY k.kontribusi_id LIMIT 8;

-- E5 Kontrol dua mart yang konsisten dengan Sesi 3, Jan-Mar 2026.
SELECT COUNT(*) AS jumlah_transaksi,SUM(jumlah_kontribusi) AS total_rupiah
FROM kontribusi WHERE status_kontribusi='LUNAS'
AND tanggal_kontribusi>='2026-01-01' AND tanggal_kontribusi<'2026-04-01';
SELECT COUNT(*) AS jumlah_klaim,SUM(nilai_bayar) AS total_rupiah
FROM klaim WHERE status_klaim='DIBAYAR'
AND tanggal_bayar>='2026-01-01' AND tanggal_bayar<'2026-04-01';

-- E6 Satu contoh klaim berbeda bulan pengajuan vs pembayaran.
SELECT klaim_id,tanggal_pengajuan,tanggal_bayar FROM klaim WHERE klaim_id=2;
-- Kegiatan utama: tulis grain, mapping, diagram, dan strategi SCD.
-- Nama claim / contribution di slide memakai klaim / kontribusi pada dataset ini.
