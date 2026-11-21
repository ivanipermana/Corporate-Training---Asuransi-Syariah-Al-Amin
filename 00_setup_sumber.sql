-- Salinan mandiri dataset Sesi 1. Tidak mengubah database Sesi 1.
-- Jalankan sekali pada server MariaDB lab. Bila nama sudah dipakai,
-- ganti nama database di CREATE DATABASE dan USE serta skrip eksplorasi.
-- CREATE DATABASE sengaja tanpa IF NOT EXISTS agar tidak tercampur database lama.
CREATE DATABASE lab_asuransi_sesi2_sumber;
USE lab_asuransi_sesi2_sumber;
CREATE TABLE produk (
 produk_id INT PRIMARY KEY, nama_produk VARCHAR(80) NOT NULL);
CREATE TABLE peserta (
 peserta_id INT PRIMARY KEY, nama_peserta VARCHAR(80) NOT NULL,
 kota VARCHAR(40) NOT NULL);
CREATE TABLE polis (
 polis_id INT PRIMARY KEY, nomor_polis VARCHAR(30) NOT NULL UNIQUE,
 peserta_id INT NOT NULL, produk_id INT NOT NULL,
 tanggal_mulai DATE NOT NULL, tanggal_akhir DATE NOT NULL,
 FOREIGN KEY (peserta_id) REFERENCES peserta(peserta_id),
 FOREIGN KEY (produk_id) REFERENCES produk(produk_id));
CREATE TABLE kontribusi (
 kontribusi_id INT PRIMARY KEY, polis_id INT NOT NULL,
 tanggal_kontribusi DATE NOT NULL, jumlah_kontribusi DECIMAL(15,2) NOT NULL,
 status_kontribusi VARCHAR(15) NOT NULL,
 FOREIGN KEY (polis_id) REFERENCES polis(polis_id));
CREATE TABLE klaim (
 klaim_id INT PRIMARY KEY, polis_id INT NOT NULL,
 tanggal_pengajuan DATE NOT NULL, tanggal_bayar DATE NULL,
 nilai_pengajuan DECIMAL(15,2) NOT NULL, nilai_bayar DECIMAL(15,2) NOT NULL,
 status_klaim VARCHAR(15) NOT NULL,
 FOREIGN KEY (polis_id) REFERENCES polis(polis_id));
INSERT INTO produk VALUES
(1, 'Proteksi Jiwa'),
(2, 'Proteksi Pembiayaan'),
(3, 'Proteksi Keluarga');
INSERT INTO peserta VALUES
(1, 'Peserta Sintetis 01', 'Jakarta'),
(2, 'Peserta Sintetis 02', 'Bandung'),
(3, 'Peserta Sintetis 03', 'Surabaya'),
(4, 'Peserta Sintetis 04', 'Jakarta'),
(5, 'Peserta Sintetis 05', 'Bandung'),
(6, 'Peserta Sintetis 06', 'Surabaya'),
(7, 'Peserta Sintetis 07', 'Jakarta'),
(8, 'Peserta Sintetis 08', 'Bandung'),
(9, 'Peserta Sintetis 09', 'Surabaya'),
(10, 'Peserta Sintetis 10', 'Jakarta'),
(11, 'Peserta Sintetis 11', 'Bandung'),
(12, 'Peserta Sintetis 12', 'Surabaya');
INSERT INTO polis VALUES
(1, 'LAB-001', 1, 1, '2026-01-01', '2026-12-31'),
(2, 'LAB-002', 2, 2, '2026-01-01', '2026-12-31'),
(3, 'LAB-003', 3, 3, '2026-01-01', '2026-12-31'),
(4, 'LAB-004', 4, 1, '2026-01-01', '2026-12-31'),
(5, 'LAB-005', 5, 2, '2026-01-01', '2026-12-31'),
(6, 'LAB-006', 6, 3, '2026-01-01', '2026-12-31'),
(7, 'LAB-007', 7, 1, '2026-01-01', '2026-12-31'),
(8, 'LAB-008', 8, 2, '2026-01-01', '2026-12-31'),
(9, 'LAB-009', 9, 3, '2026-01-01', '2026-12-31'),
(10, 'LAB-010', 10, 1, '2026-01-01', '2026-12-31'),
(11, 'LAB-011', 11, 2, '2026-01-01', '2026-12-31'),
(12, 'LAB-012', 12, 3, '2026-01-01', '2026-12-31'),
(13, 'LAB-013', 1, 1, '2026-01-01', '2026-12-31'),
(14, 'LAB-014', 2, 2, '2026-01-01', '2026-12-31'),
(15, 'LAB-015', 3, 3, '2026-01-01', '2026-12-31'),
(16, 'LAB-016', 4, 1, '2026-01-01', '2026-02-28'),
(17, 'LAB-017', 5, 2, '2026-01-01', '2026-02-28'),
(18, 'LAB-018', 6, 3, '2026-01-01', '2026-02-28');
INSERT INTO kontribusi VALUES
(1, 1, '2026-01-10', 100000, 'LUNAS'),
(2, 1, '2026-02-10', 100000, 'LUNAS'),
(3, 1, '2026-03-10', 100000, 'LUNAS'),
(4, 2, '2026-01-10', 150000, 'LUNAS'),
(5, 2, '2026-02-10', 150000, 'LUNAS'),
(6, 2, '2026-03-10', 150000, 'LUNAS'),
(7, 3, '2026-01-10', 200000, 'LUNAS'),
(8, 3, '2026-02-10', 200000, 'LUNAS'),
(9, 3, '2026-03-10', 200000, 'LUNAS'),
(10, 4, '2026-01-10', 100000, 'LUNAS'),
(11, 4, '2026-02-10', 100000, 'LUNAS'),
(12, 4, '2026-03-10', 100000, 'LUNAS'),
(13, 5, '2026-01-10', 150000, 'LUNAS'),
(14, 5, '2026-02-10', 150000, 'LUNAS'),
(15, 5, '2026-03-10', 150000, 'TERTUNDA'),
(16, 6, '2026-01-10', 200000, 'LUNAS'),
(17, 6, '2026-02-10', 200000, 'LUNAS'),
(18, 6, '2026-03-10', 200000, 'LUNAS'),
(19, 7, '2026-01-10', 100000, 'LUNAS'),
(20, 7, '2026-02-10', 100000, 'LUNAS'),
(21, 7, '2026-03-10', 100000, 'LUNAS'),
(22, 8, '2026-01-10', 150000, 'LUNAS'),
(23, 8, '2026-02-10', 150000, 'LUNAS'),
(24, 8, '2026-03-10', 150000, 'LUNAS'),
(25, 9, '2026-01-10', 200000, 'LUNAS'),
(26, 9, '2026-02-10', 200000, 'LUNAS'),
(27, 9, '2026-03-10', 200000, 'LUNAS'),
(28, 10, '2026-01-10', 100000, 'LUNAS'),
(29, 10, '2026-02-10', 100000, 'LUNAS'),
(30, 10, '2026-03-10', 100000, 'TERTUNDA'),
(31, 11, '2026-01-10', 150000, 'LUNAS'),
(32, 11, '2026-02-10', 150000, 'LUNAS'),
(33, 11, '2026-03-10', 150000, 'LUNAS'),
(34, 12, '2026-01-10', 200000, 'LUNAS'),
(35, 12, '2026-02-10', 200000, 'LUNAS'),
(36, 12, '2026-03-10', 200000, 'LUNAS'),
(37, 13, '2026-01-10', 100000, 'LUNAS'),
(38, 13, '2026-02-10', 100000, 'LUNAS'),
(39, 13, '2026-03-10', 100000, 'LUNAS'),
(40, 14, '2026-01-10', 150000, 'LUNAS'),
(41, 14, '2026-02-10', 150000, 'LUNAS'),
(42, 14, '2026-03-10', 150000, 'LUNAS'),
(43, 15, '2026-01-10', 200000, 'LUNAS'),
(44, 15, '2026-02-10', 200000, 'LUNAS'),
(45, 15, '2026-03-10', 200000, 'TERTUNDA'),
(46, 16, '2026-01-10', 100000, 'LUNAS'),
(47, 16, '2026-02-10', 100000, 'LUNAS'),
(48, 16, '2026-03-10', 100000, 'LUNAS'),
(49, 17, '2026-01-10', 150000, 'LUNAS'),
(50, 17, '2026-02-10', 150000, 'LUNAS'),
(51, 17, '2026-03-10', 150000, 'LUNAS'),
(52, 18, '2026-01-10', 200000, 'LUNAS'),
(53, 18, '2026-02-10', 200000, 'LUNAS'),
(54, 18, '2026-03-10', 200000, 'BATAL');
INSERT INTO klaim VALUES
(1, 1, '2026-01-12', '2026-01-25', 2000000, 1800000, 'DIBAYAR'),
(2, 1, '2026-02-10', '2026-03-05', 1000000, 900000, 'DIBAYAR'),
(3, 2, '2026-02-11', '2026-02-25', 3000000, 2500000, 'DIBAYAR'),
(4, 3, '2026-03-01', NULL, 1500000, 0, 'DIAJUKAN'),
(5, 4, '2026-03-02', NULL, 2500000, 0, 'DITOLAK'),
(6, 5, '2026-03-10', '2026-03-20', 4000000, 3500000, 'DIBAYAR'),
(7, 6, '2026-03-12', NULL, 2200000, 0, 'DISETUJUI'),
(8, 7, '2026-01-05', '2026-02-01', 1200000, 1000000, 'DIBAYAR'),
(9, 8, '2026-03-20', NULL, 1800000, 0, 'DIAJUKAN');
