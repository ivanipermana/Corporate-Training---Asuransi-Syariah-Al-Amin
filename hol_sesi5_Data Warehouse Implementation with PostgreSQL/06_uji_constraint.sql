-- PostgreSQL DO block, jalankan setelah seed. Menangkap HANYA error yang diharapkan.
-- Subtransaksi otomatis membatalkan INSERT gagal. Tidak meninggalkan baris uji.
-- Jika constraint hilang, RAISE EXCEPTION membuat tes gagal dan membatalkan INSERT.

DO $$
BEGIN
 BEGIN
  INSERT INTO mart.fact_contribution_receipt VALUES (9001,'UJI',91,20260110,999,21,101,100,1);
  RAISE EXCEPTION 'GAGAL: FK tidak ditemukan justru diterima';
 EXCEPTION WHEN foreign_key_violation THEN
  RAISE NOTICE 'LULUS: FK tidak ditemukan ditolak';
 END;
END $$;

DO $$
BEGIN
 BEGIN
  INSERT INTO mart.fact_contribution_receipt VALUES (9002,'LAB',1,20260110,11,21,101,100,1);
  RAISE EXCEPTION 'GAGAL: Grain duplikat dengan PK baru justru diterima';
 EXCEPTION WHEN unique_violation THEN
  RAISE NOTICE 'LULUS: Grain duplikat dengan PK baru ditolak';
 END;
END $$;

DO $$
BEGIN
 BEGIN
  INSERT INTO mart.fact_claim_payment VALUES (9003,'UJI',93,20260125,11,21,101,-100,1);
  RAISE EXCEPTION 'GAGAL: Nilai negatif justru diterima';
 EXCEPTION WHEN check_violation THEN
  RAISE NOTICE 'LULUS: Nilai negatif ditolak';
 END;
END $$;

DO $$
BEGIN
 BEGIN
  INSERT INTO mart.fact_claim_payment VALUES (9004,'UJI',94,20260125,NULL,21,101,100,1);
  RAISE EXCEPTION 'GAGAL: FK NULL justru diterima';
 EXCEPTION WHEN not_null_violation THEN
  RAISE NOTICE 'LULUS: FK NULL ditolak';
 END;
END $$;

DO $$
BEGIN
 BEGIN
  INSERT INTO mart.fact_claim_payment VALUES (9005,'UJI',95,20260125,11,21,101,100,2);
  RAISE EXCEPTION 'GAGAL: Count bukan satu justru diterima';
 EXCEPTION WHEN check_violation THEN
  RAISE NOTICE 'LULUS: Count bukan satu ditolak';
 END;
END $$;

SELECT COUNT(*) AS baris_tetap_6 FROM mart.fact_contribution_receipt;
SELECT COUNT(*) AS baris_tetap_3 FROM mart.fact_claim_payment;
