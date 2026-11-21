-- LATIHAN LANJUTAN OPSIONAL. File ini sengaja hanya berisi komentar.
-- Susun DDL pada database model baru milik kelompok, jangan ALTER sumber.
-- Ganti seluruh [placeholder] sebelum membuka komentar dan mengeksekusi.
-- Hindari DDL dalam transaksi uji; DDL dapat melakukan implicit commit.

-- CREATE DATABASE [nama_database_model_kelompok];
-- USE [nama_database_model_kelompok];

-- Contoh lengkap satu entitas konteks:
-- CREATE TABLE produk (
--   produk_id INT NOT NULL,
--   nama_produk VARCHAR(80) NOT NULL,
--   PRIMARY KEY (produk_id)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Urutan pembuatan: produk, peserta, polis, kontribusi, klaim.
-- Tugas: tulis CREATE TABLE peserta, polis, kontribusi, klaim.
-- Untuk Polis: PK, nomor polis unik, dua FK NOT NULL, serta CHECK periode.
-- Untuk Klaim: PK, FK NOT NULL, tanggal_bayar nullable, DECIMAL untuk rupiah,
--             dan aturan konsistensi status / tanggal / nilai pembayaran.
-- Nyatakan ON DELETE / ON UPDATE. Uji penolakan pada data uji terpisah.
-- Catat perubahan dari sumber; contoh DEFAULT 0 nilai_bayar adalah USULAN.
