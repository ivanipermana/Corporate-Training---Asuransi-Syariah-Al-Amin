-- PostgreSQL saja. Jalankan pada database lab khusus kelompok yang telah disiapkan.
-- DBeaver: pilih koneksi PostgreSQL, buka SQL Editor, Execute SQL Script (Alt+X).
-- Konfirmasi server dan database sebelum membuat objek.
SELECT version(), current_database(), current_user;
SELECT schema_name FROM information_schema.schemata
WHERE schema_name IN ('staging','mart');
-- Hasil query kedua HARUS kosong untuk memulai. Jika ada, gunakan database lab baru.
-- Tidak ada DROP, TRUNCATE, atau penggantian objek sesi sebelumnya.
