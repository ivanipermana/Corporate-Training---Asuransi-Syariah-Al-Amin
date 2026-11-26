-- PostgreSQL. Setelah lima tabel raw ditransfer, definisikan view sekali.
-- DDL view bukan perintah untuk diulang saat demo incremental; view membaca raw terbaru.
CREATE VIEW s6_staging.clean_product AS
SELECT product_id,UPPER(TRIM(product_code)) AS product_code,
 COALESCE(NULLIF(TRIM(product_name),''),'Produk '||UPPER(TRIM(product_code))) AS product_name
FROM s6_staging.product;
CREATE VIEW s6_staging.clean_participant AS
SELECT participant_id,TRIM(participant_name) AS participant_name,
 COALESCE(NULLIF(TRIM(city),''),'TIDAK DIKETAHUI') AS city
FROM s6_staging.participant;
CREATE VIEW s6_staging.valid_policy AS
SELECT p.policy_id,TRIM(p.policy_number) AS policy_number,
 pr.product_code,p.participant_id
FROM s6_staging.policy p
JOIN s6_staging.clean_product pr ON pr.product_code=UPPER(TRIM(p.product_code))
JOIN s6_staging.clean_participant pe ON pe.participant_id=p.participant_id
WHERE pr.product_code IS NOT NULL AND pr.product_code<>''
 AND TRIM(p.policy_number)<>'' AND pe.participant_name IS NOT NULL AND pe.participant_name<>'';

CREATE VIEW s6_staging.classified_contribution AS
SELECT x.*,CASE
 WHEN UPPER(TRIM(x.status)) IS NULL OR UPPER(TRIM(x.status)) NOT IN
 ('LUNAS','TERTUNDA','BATAL') THEN 'REJECT_STATUS'
 WHEN UPPER(TRIM(x.status))<>'LUNAS' THEN 'EXCLUDED_STATUS'
 WHEN x.amount IS NULL OR x.amount<=0 THEN 'REJECT_AMOUNT'
 WHEN x.event_date IS NULL THEN 'REJECT_DATE'
 WHEN x.event_date<'2026-01-01' OR x.event_date>='2026-04-01' THEN 'EXCLUDED_PERIOD'
 
 WHEN p.policy_id IS NULL THEN 'REJECT_POLICY'
 WHEN pr.product_id IS NULL THEN 'REJECT_PRODUCT'
 WHEN pe.participant_id IS NULL OR pe.participant_name IS NULL OR pe.participant_name='' THEN 'REJECT_PARTICIPANT'
 WHEN v.policy_id IS NULL THEN 'REJECT_POLICY_ATTRIBUTE'
 ELSE 'ELIGIBLE' END AS disposition
FROM s6_staging.contribution x
LEFT JOIN s6_staging.policy p ON p.policy_id=x.policy_id
LEFT JOIN s6_staging.clean_product pr ON pr.product_code=UPPER(TRIM(p.product_code))
LEFT JOIN s6_staging.clean_participant pe ON pe.participant_id=p.participant_id
LEFT JOIN s6_staging.valid_policy v ON v.policy_id=p.policy_id;

CREATE VIEW s6_staging.classified_claim AS
SELECT x.*,CASE
 WHEN UPPER(TRIM(x.status)) IS NULL OR UPPER(TRIM(x.status)) NOT IN
 ('DIBAYAR','DIAJUKAN','DISETUJUI','DITOLAK') THEN 'REJECT_STATUS'
 WHEN UPPER(TRIM(x.status))<>'DIBAYAR' THEN 'EXCLUDED_STATUS'
 WHEN x.paid_amount IS NULL OR x.paid_amount<=0 THEN 'REJECT_AMOUNT'
 WHEN x.paid_date IS NULL THEN 'REJECT_DATE'
 WHEN x.paid_date<'2026-01-01' OR x.paid_date>='2026-04-01' THEN 'EXCLUDED_PERIOD'
 WHEN x.submitted_date IS NULL OR x.paid_date<x.submitted_date THEN 'REJECT_DATE_ORDER'
 WHEN p.policy_id IS NULL THEN 'REJECT_POLICY'
 WHEN pr.product_id IS NULL THEN 'REJECT_PRODUCT'
 WHEN pe.participant_id IS NULL OR pe.participant_name IS NULL OR pe.participant_name='' THEN 'REJECT_PARTICIPANT'
 WHEN v.policy_id IS NULL THEN 'REJECT_POLICY_ATTRIBUTE'
 ELSE 'ELIGIBLE' END AS disposition
FROM s6_staging.claim x
LEFT JOIN s6_staging.policy p ON p.policy_id=x.policy_id
LEFT JOIN s6_staging.clean_product pr ON pr.product_code=UPPER(TRIM(p.product_code))
LEFT JOIN s6_staging.clean_participant pe ON pe.participant_id=p.participant_id
LEFT JOIN s6_staging.valid_policy v ON v.policy_id=p.policy_id;
