-- AKTIVITAS 1. Jalankan sekali setelah 00, pada namespace kosong.
CREATE SCHEMA staging;
CREATE SCHEMA mart;
CREATE TABLE staging.contribution_sample (
 kontribusi_id BIGINT PRIMARY KEY,
 polis_id INTEGER NOT NULL,
 tanggal_kontribusi DATE NOT NULL,
 jumlah_kontribusi NUMERIC(15,2) NOT NULL,
 status_kontribusi TEXT NOT NULL
);
-- TODO A: buat staging.claim_sample dengan enam kolom berikut.
-- klaim_id BIGINT PK; polis_id INTEGER NOT NULL;
-- tanggal_pengajuan DATE NOT NULL; tanggal_bayar DATE nullable;
-- nilai_bayar NUMERIC(15,2) NOT NULL; status_klaim TEXT NOT NULL.
-- Tabel staging adalah area sampel; FK analitik dibuat pada mart.
