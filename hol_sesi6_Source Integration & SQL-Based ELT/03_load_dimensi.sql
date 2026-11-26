-- PostgreSQL. Dimensi Type 1 pada lab; tidak mengklaim mempertahankan histori SCD2.
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

INSERT INTO s6_mart.dim_product(product_code,product_name)
SELECT product_code,product_name FROM s6_staging.clean_product WHERE TRUE
ON CONFLICT(product_code) DO UPDATE SET product_name=EXCLUDED.product_name;
INSERT INTO s6_mart.dim_participant(participant_id,participant_name,city)
SELECT participant_id,participant_name,city FROM s6_staging.clean_participant
WHERE participant_name IS NOT NULL AND participant_name<>''
ON CONFLICT(participant_id) DO UPDATE SET participant_name=EXCLUDED.participant_name,city=EXCLUDED.city;
INSERT INTO s6_mart.dim_policy(policy_id,policy_number)
SELECT policy_id,policy_number FROM s6_staging.valid_policy WHERE TRUE
ON CONFLICT(policy_id) DO UPDATE SET policy_number=EXCLUDED.policy_number;
INSERT INTO s6_mart.dim_date(date_key,calendar_date)
SELECT CAST(TO_CHAR(d,'YYYYMMDD') AS INTEGER),d FROM (
 SELECT event_date AS d FROM s6_staging.classified_contribution WHERE disposition='ELIGIBLE'
 UNION SELECT paid_date FROM s6_staging.classified_claim WHERE disposition='ELIGIBLE') q
WHERE TRUE ON CONFLICT(date_key) DO NOTHING;
COMMIT;
