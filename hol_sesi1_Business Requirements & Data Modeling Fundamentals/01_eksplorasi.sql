USE lab_asuransi_konseptual;
SHOW TABLES;
DESCRIBE polis;
-- Ulangi DESCRIBE dan SELECT LIMIT untuk semua tabel.
SELECT * FROM peserta LIMIT 5;
SELECT * FROM polis LIMIT 5;
SELECT * FROM kontribusi LIMIT 5;
SELECT * FROM klaim LIMIT 5;
SELECT * FROM produk LIMIT 5;
SELECT status_kontribusi, COUNT(*) AS jumlah FROM kontribusi GROUP BY status_kontribusi;
SELECT status_klaim, COUNT(*) AS jumlah FROM klaim GROUP BY status_klaim;
-- Tantangan: cari kolom penghubung, tanggal acuan, dan satuan setiap tabel.
-- Tidak wajib menulis query KPI selama 45 menit. Fokus pada dua deliverable.
