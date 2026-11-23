-- SKENARIO TAMBAHAN SINTETIS. Bukan histori yang ditemukan di sumber utama.
-- Jalankan pada koneksi MariaDB lab yang sama sepanjang latihan.
-- TEMPORARY TABLE hilang ketika koneksi ditutup. Tidak mengubah tabel peserta.
-- Jika dijalankan ulang pada koneksi sama, tutup koneksi lab lalu sambungkan ulang.
USE lab_asuransi_sesi4_sumber;
CREATE TEMPORARY TABLE lab4_dim_participant_demo (
 participant_key INT PRIMARY KEY, peserta_id INT NOT NULL,
 kota VARCHAR(40) NOT NULL, valid_from DATE NOT NULL, valid_to DATE NULL,
 is_current INT NOT NULL);
INSERT INTO lab4_dim_participant_demo VALUES
 (101,1,'Jakarta','2026-01-01','2026-03-01',0),
 (102,1,'Bandung','2026-03-01',NULL,1);

CREATE TEMPORARY TABLE lab4_event_demo (
 kontribusi_id INT PRIMARY KEY,peserta_id INT NOT NULL,
 tanggal_event DATE NOT NULL,jumlah_kontribusi DECIMAL(15,2) NOT NULL);
INSERT INTO lab4_event_demo VALUES
 (1,1,'2026-01-10',100000),
 (2,1,'2026-02-10',100000),
 (3,1,'2026-03-10',100000);

SELECT * FROM lab4_dim_participant_demo ORDER BY participant_key;
SELECT * FROM lab4_event_demo ORDER BY kontribusi_id;
-- Tugas: tentukan participant_key untuk tiga event tersebut.
-- Kontrak periode: valid_from inklusif; valid_to eksklusif; NULL = masih berlaku.
-- Tantangan opsional: tulis JOIN dengan peserta_id dan rentang tanggal event.
-- Jangan memakai is_current=1 untuk semua transaksi historis.
-- Jawaban tersedia hanya pada folder fasilitator.
