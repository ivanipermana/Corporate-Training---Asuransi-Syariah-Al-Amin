-- MariaDB: sumber Sesi 6 baru, bukan schema sumber sesi sebelumnya.
USE lab_asuransi_sesi6_source;
SELECT DATABASE(),VERSION();
SELECT 'product' AS tabel,COUNT(*) AS baris,COUNT(DISTINCT product_id) AS id_unik FROM product;
SELECT 'participant' AS tabel,COUNT(*) AS baris,COUNT(DISTINCT participant_id) AS id_unik FROM participant;
SELECT 'policy' AS tabel,COUNT(*) AS baris,COUNT(DISTINCT policy_id) AS id_unik FROM policy;
SELECT 'contribution' AS tabel,COUNT(*) AS baris,COUNT(DISTINCT event_id) AS id_unik FROM contribution;
SELECT 'claim' AS tabel,COUNT(*) AS baris,COUNT(DISTINCT event_id) AS id_unik FROM claim;
SELECT UPPER(TRIM(product_code)) AS canonical_code,COUNT(*) AS n
FROM product GROUP BY UPPER(TRIM(product_code)) HAVING COUNT(*)>1;
SELECT COUNT(*) AS raw_rows,SUM(amount) AS raw_amount FROM contribution;
SELECT COUNT(*) AS raw_rows,SUM(paid_amount) AS raw_amount FROM claim;
-- Kontrol snapshot RAW awal: product2 participant2 policy3 contribution9 claim5.
-- Raw kontribusi 810000; raw nilai_bayar 5500000. Bukan total mart.
-- Export kelima tabel dengan semua kolom, tanpa filter; sertakan NULL dan header.

-- Kontrol ELIGIBLE independen pada MariaDB, bukan SUM semua status.
-- Simpan hasil sebelum transfer, ulang setelah 05a untuk kontrol delta.
SELECT 'contribution' AS proses,COUNT(*) AS eligible_rows,SUM(x.amount) AS eligible_amount
FROM contribution x
JOIN policy p ON p.policy_id=x.policy_id
JOIN product pr ON UPPER(TRIM(pr.product_code))=UPPER(TRIM(p.product_code))
JOIN participant pe ON pe.participant_id=p.participant_id
WHERE UPPER(TRIM(x.status))='LUNAS' AND x.amount>0
 AND x.event_date>='2026-01-01' AND x.event_date<'2026-04-01'
 AND TRIM(p.policy_number)<>'' AND TRIM(pe.participant_name)<>''
 AND TRIM(pr.product_code)<>''
 ;

-- Kontrol ELIGIBLE independen pada MariaDB, bukan SUM semua status.
-- Simpan hasil sebelum transfer, ulang setelah 05a untuk kontrol delta.
SELECT 'claim' AS proses,COUNT(*) AS eligible_rows,SUM(x.paid_amount) AS eligible_amount
FROM claim x
JOIN policy p ON p.policy_id=x.policy_id
JOIN product pr ON UPPER(TRIM(pr.product_code))=UPPER(TRIM(p.product_code))
JOIN participant pe ON pe.participant_id=p.participant_id
WHERE UPPER(TRIM(x.status))='DIBAYAR' AND x.paid_amount>0
 AND x.paid_date>='2026-01-01' AND x.paid_date<'2026-04-01'
 AND TRIM(p.policy_number)<>'' AND TRIM(pe.participant_name)<>''
 AND TRIM(pr.product_code)<>''
 AND x.submitted_date IS NOT NULL AND x.paid_date>=x.submitted_date;
