-- PostgreSQL. Dapat diulang; satu penulis lab, snapshot raw lengkap.
BEGIN;
-- Guard snapshot lengkap. Jalankan di dalam transaksi load.
DO $$
BEGIN
 IF EXISTS (
  SELECT 1 FROM s6_staging.manifest m JOIN (
   SELECT 'product' AS t,COUNT(*) AS n FROM s6_staging.product UNION ALL
   SELECT 'participant',COUNT(*) FROM s6_staging.participant UNION ALL
   SELECT 'policy',COUNT(*) FROM s6_staging.policy UNION ALL
   SELECT 'contribution',COUNT(*) FROM s6_staging.contribution UNION ALL
   SELECT 'claim',COUNT(*) FROM s6_staging.claim) x ON x.t=m.table_name
  WHERE x.n<>m.expected_rows
 ) OR (SELECT COUNT(*) FROM s6_staging.manifest)<>5 THEN
  RAISE EXCEPTION 'STOP: source manifest berbeda dengan staging';
 END IF;
 IF EXISTS (SELECT product_code FROM s6_staging.clean_product
   GROUP BY product_code HAVING COUNT(*)>1)
 OR EXISTS (SELECT 1 FROM s6_staging.clean_product WHERE product_code IS NULL OR product_code='')
 OR EXISTS (SELECT policy_number FROM s6_staging.valid_policy GROUP BY policy_number HAVING COUNT(*)>1)
 THEN RAISE EXCEPTION 'STOP: key dimensi kosong atau duplikat setelah cleansing'; END IF;
END $$;
INSERT INTO s6_mart.fact_contribution_receipt
 (source_system,event_id,contribution_date_key,product_key,policy_key,participant_key,amount)
SELECT 'LAB6',x.event_id,d.date_key,pr.product_key,po.policy_key,pe.participant_key,x.amount
FROM s6_staging.classified_contribution x
JOIN s6_staging.valid_policy p ON p.policy_id=x.policy_id
JOIN s6_mart.dim_product pr ON pr.product_code=p.product_code
JOIN s6_mart.dim_policy po ON po.policy_id=p.policy_id
JOIN s6_mart.dim_participant pe ON pe.participant_id=p.participant_id
JOIN s6_mart.dim_date d ON d.calendar_date=x.event_date
WHERE x.disposition='ELIGIBLE'
ON CONFLICT(source_system,event_id) DO UPDATE SET
 contribution_date_key=EXCLUDED.contribution_date_key,product_key=EXCLUDED.product_key,
 policy_key=EXCLUDED.policy_key,participant_key=EXCLUDED.participant_key,amount=EXCLUDED.amount;
-- Hapus hanya event lab yang MASIH ada di raw dan kini tidak eligible.
-- Source hard-delete tidak ditangani; perlu tombstone/CDC pada pipeline produksi.
DELETE FROM s6_mart.fact_contribution_receipt f WHERE f.source_system='LAB6'
 AND EXISTS(SELECT 1 FROM s6_staging.classified_contribution x
 WHERE x.event_id=f.event_id AND x.disposition<>'ELIGIBLE');
-- TODO F: lengkapi INSERT SELECT untuk s6_mart.fact_claim_payment.
-- Ikuti contoh kontribusi: x = classified_claim, filter ELIGIBLE, x.paid_amount.
-- Join valid_policy lalu empat dimensi; calendar_date=x.paid_date.
-- Kolom tanggal target payment_date_key. source_system LAB6.
-- ON CONFLICT(source_system,event_id) DO UPDATE: tanggal, tiga key lain, amount.
-- Tulis di sini SEBELUM DELETE klaim dan COMMIT.

-- Hapus hanya event lab yang MASIH ada di raw dan kini tidak eligible.
-- Source hard-delete tidak ditangani; perlu tombstone/CDC pada pipeline produksi.
DELETE FROM s6_mart.fact_claim_payment f WHERE f.source_system='LAB6'
 AND EXISTS(SELECT 1 FROM s6_staging.classified_claim x
 WHERE x.event_id=f.event_id AND x.disposition<>'ELIGIBLE');
COMMIT;
