-- READ ONLY. Semua kontrol pelanggaran seharusnya bernilai 0 pada fixture bersih.
USE lab_asuransi_sesi2_sumber;
-- V1 Jumlah record: 3, 12, 18, 54, 9.
SELECT 'produk' AS tabel, COUNT(*) AS jumlah FROM produk
UNION ALL SELECT 'peserta', COUNT(*) FROM peserta
UNION ALL SELECT 'polis', COUNT(*) FROM polis
UNION ALL SELECT 'kontribusi', COUNT(*) FROM kontribusi
UNION ALL SELECT 'klaim', COUNT(*) FROM klaim;

-- V2 Orphan: validasi semua empat jalur FK, termasuk jika constraint tidak tersedia.
SELECT 'polis_peserta' AS relasi, COUNT(*) AS orphan FROM polis c LEFT JOIN peserta p ON c.peserta_id=p.peserta_id WHERE p.peserta_id IS NULL
UNION ALL SELECT 'polis_produk',COUNT(*) FROM polis c LEFT JOIN produk p ON c.produk_id=p.produk_id WHERE p.produk_id IS NULL
UNION ALL SELECT 'kontribusi_polis',COUNT(*) FROM kontribusi c LEFT JOIN polis p ON c.polis_id=p.polis_id WHERE p.polis_id IS NULL
UNION ALL SELECT 'klaim_polis',COUNT(*) FROM klaim c LEFT JOIN polis p ON c.polis_id=p.polis_id WHERE p.polis_id IS NULL;

-- V3 Nomor bisnis polis duplikat: hasil kosong.
SELECT nomor_polis, COUNT(*) AS jumlah FROM polis GROUP BY nomor_polis HAVING COUNT(*) > 1;

-- V4 Rentang tanggal polis tidak valid.
SELECT COUNT(*) AS periode_polis_tidak_valid FROM polis WHERE tanggal_akhir < tanggal_mulai;

-- V5 Inkonsistensi status pembayaran klaim.
SELECT COUNT(*) AS pembayaran_tidak_konsisten FROM klaim
WHERE (status_klaim = 'DIBAYAR' AND (tanggal_bayar IS NULL OR nilai_bayar <= 0))
   OR (status_klaim <> 'DIBAYAR' AND (tanggal_bayar IS NOT NULL OR nilai_bayar <> 0));

-- V6 Nilai / urutan tanggal yang perlu ditinjau.
SELECT COUNT(*) AS nilai_kontribusi_tidak_valid FROM kontribusi WHERE jumlah_kontribusi <= 0;
SELECT COUNT(*) AS nilai_klaim_tidak_valid FROM klaim
WHERE nilai_pengajuan <= 0 OR nilai_bayar < 0 OR nilai_bayar > nilai_pengajuan
   OR tanggal_bayar < tanggal_pengajuan;

-- V7 Kontrol KPI: 7450000; 15; 9700000.
SELECT SUM(jumlah_kontribusi) AS kontribusi_lunas FROM kontribusi
WHERE status_kontribusi='LUNAS' AND tanggal_kontribusi >= '2026-01-01' AND tanggal_kontribusi < '2026-04-01';
SELECT COUNT(DISTINCT polis_id) AS polis_aktif FROM polis
WHERE tanggal_mulai <= '2026-03-31' AND tanggal_akhir >= '2026-03-31';
SELECT SUM(nilai_bayar) AS klaim_dibayar FROM klaim
WHERE status_klaim='DIBAYAR' AND tanggal_bayar >= '2026-01-01' AND tanggal_bayar < '2026-04-01';

-- V8 Bukti fan-out: 6 baris walaupun kontribusi 3 dan klaim 2 untuk polis 1.
SELECT COUNT(*) AS baris_join FROM kontribusi k JOIN klaim c ON c.polis_id=k.polis_id
WHERE k.polis_id=1;
