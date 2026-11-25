-- AKTIVITAS 3. Jalankan SEKALI setelah semua tabel siap. Semua data sintetis.
-- Sampel kecil mengikuti transaksi polis 1 dan 2, bukan seluruh dataset sesi sebelumnya.
-- Asumsi fixture: kota peserta tetap sepanjang Jan-Mar. Tidak ada load SCD otomatis.
-- source_system adalah metadata lineage lab yang diberikan saat pengisian, bukan kolom sumber lama.
BEGIN;
INSERT INTO staging.contribution_sample
 (kontribusi_id,polis_id,tanggal_kontribusi,jumlah_kontribusi,status_kontribusi) VALUES
 (1,1,'2026-01-10',100000,'LUNAS'),(2,1,'2026-02-10',100000,'LUNAS'),
 (3,1,'2026-03-10',100000,'LUNAS'),(4,2,'2026-01-10',150000,'LUNAS'),
 (5,2,'2026-02-10',150000,'LUNAS'),(6,2,'2026-03-10',150000,'LUNAS');
INSERT INTO staging.claim_sample
 (klaim_id,polis_id,tanggal_pengajuan,tanggal_bayar,nilai_bayar,status_klaim) VALUES
 (1,1,'2026-01-12','2026-01-25',1800000,'DIBAYAR'),
 (2,1,'2026-02-10','2026-03-05',900000,'DIBAYAR'),
 (3,2,'2026-02-11','2026-02-25',2500000,'DIBAYAR');
INSERT INTO mart.dim_date (date_key,calendar_date,month_number,year_number) VALUES
 (20260110,'2026-01-10',1,2026),(20260210,'2026-02-10',2,2026),
 (20260310,'2026-03-10',3,2026),(20260125,'2026-01-25',1,2026),
 (20260305,'2026-03-05',3,2026),(20260225,'2026-02-25',2,2026);
INSERT INTO mart.dim_product (product_key,source_system,produk_id,nama_produk) VALUES
 (11,'LAB',1,'Proteksi Jiwa'),(12,'LAB',2,'Proteksi Pembiayaan');
INSERT INTO mart.dim_participant
 (participant_key,source_system,peserta_id,nama_peserta,kota,valid_from,valid_to,is_current) VALUES
 (101,'LAB',1,'Peserta Sintetis 01','Jakarta','2026-01-01',NULL,TRUE),
 (102,'LAB',2,'Peserta Sintetis 02','Bandung','2026-01-01',NULL,TRUE);
INSERT INTO mart.dim_policy
 (policy_key,source_system,polis_id,nomor_polis,tanggal_mulai,tanggal_akhir) VALUES
 (21,'LAB',1,'LAB-001','2026-01-01','2026-12-31'),
 (22,'LAB',2,'LAB-002','2026-01-01','2026-12-31');
-- Key analitik ditetapkan eksplisit. Ini INSERT sampel, bukan pipeline sumber-ke-target.
INSERT INTO mart.fact_contribution_receipt
 (contribution_key,source_system,kontribusi_id,contribution_date_key,
 product_key,policy_key,participant_key,jumlah_kontribusi,transaction_count) VALUES
 (1001,'LAB',1,20260110,11,21,101,100000,1),
 (1002,'LAB',2,20260210,11,21,101,100000,1),
 (1003,'LAB',3,20260310,11,21,101,100000,1),
 (1004,'LAB',4,20260110,12,22,102,150000,1),
 (1005,'LAB',5,20260210,12,22,102,150000,1),
 (1006,'LAB',6,20260310,12,22,102,150000,1);
INSERT INTO mart.fact_claim_payment
 (claim_payment_key,source_system,klaim_id,payment_date_key,
 product_key,policy_key,participant_key,nilai_bayar,paid_claim_count) VALUES
 (2001,'LAB',1,20260125,11,21,101,1800000,1),
 (2002,'LAB',2,20260305,11,21,101,900000,1),
 (2003,'LAB',3,20260225,12,22,102,2500000,1);
COMMIT;
-- Jika transaksi gagal: ROLLBACK; perbaiki struktur, kemudian ulang file ini.
-- Jika sudah sukses, jangan ulang seed. Duplikat memang harus ditolak.
