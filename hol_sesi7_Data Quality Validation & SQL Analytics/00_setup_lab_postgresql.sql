-- PostgreSQL. Fasilitator menjalankan SEKALI sebelum timer pada database lab.
-- Schema khusus Sesi 7; tidak mengganti mart sesi sebelumnya.
CREATE SCHEMA s7_source;
CREATE SCHEMA s7_reference;
CREATE SCHEMA s7_audit;
CREATE SCHEMA s7_mart;
-- row_id adalah identitas fisik landing; event_id adalah natural business ID.
-- Source sengaja tanpa UNIQUE business ID/FK agar peserta dapat menemukan isu.
CREATE TABLE s7_source.contribution (
 row_id INTEGER PRIMARY KEY,source_system TEXT,event_id INTEGER,policy_id INTEGER,
 event_date DATE,amount NUMERIC(15,2),status TEXT);
CREATE TABLE s7_source.claim (
 row_id INTEGER PRIMARY KEY,source_system TEXT,event_id INTEGER,policy_id INTEGER,
 submitted_date DATE,paid_date DATE,amount NUMERIC(15,2),status TEXT);
INSERT INTO s7_source.contribution VALUES
 (1,'LAB7',1,1,'2026-01-10',100000,'LUNAS'),
 (2,'LAB7',2,1,'2026-02-10',100000,'LUNAS'),
 (3,'LAB7',3,1,'2026-03-10',100000,'LUNAS'),
 (4,'LAB7',4,2,'2026-01-10',150000,'LUNAS'),
 (5,'LAB7',5,2,'2026-02-10',150000,'LUNAS'),
 (6,'LAB7',6,2,'2026-03-10',150000,'LUNAS'),
 (7,'LAB7',1,1,'2026-01-10',100000,'LUNAS'),
 (8,'LAB7',7,999,'2026-03-10',50000,'LUNAS'),
 (9,'LAB7',8,1,'2026-03-10',-10000,'LUNAS'),
 (10,'LAB7',9,1,'2026-03-10',NULL,'LUNAS'),
 (11,'LAB7',10,1,NULL,20000,'LUNAS'),
 (12,'LAB7',NULL,1,'2026-03-10',30000,'LUNAS'),
 (13,'LAB7',12,1,'2026-03-10',40000,'UNKNOWN'),
 (14,'LAB7',13,NULL,'2026-03-10',10000,'LUNAS'),
 (15,'LAB7',14,1,'2026-04-10',25000,'LUNAS'),
 (16,'LAB7',15,1,'2026-03-10',15000,'TERTUNDA');
INSERT INTO s7_source.claim VALUES
 (1,'LAB7',1,1,'2026-01-12','2026-01-25',1800000,'DIBAYAR'),
 (2,'LAB7',2,1,'2026-02-10','2026-03-05',900000,'DIBAYAR'),
 (3,'LAB7',3,2,'2026-02-11','2026-02-25',2500000,'DIBAYAR'),
 (4,'LAB7',4,1,'2026-03-01',NULL,500000,'DIBAYAR'),
 (5,'LAB7',5,999,'2026-03-02','2026-03-20',300000,'DIBAYAR'),
 (6,'LAB7',6,1,'2026-03-20','2026-03-10',600000,'DIBAYAR'),
 (7,'LAB7',7,1,'2026-03-02','2026-03-20',NULL,'DIBAYAR'),
 (8,'LAB7',8,1,'2026-03-10',NULL,0,'DIAJUKAN');
CREATE TABLE s7_mart.dim_product(product_key INTEGER PRIMARY KEY,product_code TEXT NOT NULL UNIQUE,product_name TEXT NOT NULL);
CREATE TABLE s7_mart.dim_participant(participant_key INTEGER PRIMARY KEY,participant_id INTEGER NOT NULL UNIQUE);
CREATE TABLE s7_mart.dim_policy(policy_key INTEGER PRIMARY KEY,policy_id INTEGER NOT NULL UNIQUE,
 product_key INTEGER NOT NULL REFERENCES s7_mart.dim_product,
 participant_key INTEGER NOT NULL REFERENCES s7_mart.dim_participant);
CREATE TABLE s7_mart.dim_date(date_key INTEGER PRIMARY KEY,calendar_date DATE NOT NULL UNIQUE);
INSERT INTO s7_mart.dim_product VALUES (11,'PJ','Proteksi Jiwa'),(12,'PP','Proteksi Pembiayaan');
INSERT INTO s7_mart.dim_participant VALUES (101,1),(102,2);
INSERT INTO s7_mart.dim_policy VALUES (21,1,11,101),(22,2,12,102);
INSERT INTO s7_mart.dim_date VALUES
 (20260110,'2026-01-10'),(20260210,'2026-02-10'),(20260310,'2026-03-10'),
 (20260125,'2026-01-25'),(20260305,'2026-03-05'),(20260225,'2026-02-25'),
 (20260205,'2026-02-05');
CREATE TABLE s7_mart.fact_contribution_receipt (
 contribution_key INTEGER PRIMARY KEY,source_system TEXT NOT NULL,event_id INTEGER NOT NULL,
 contribution_date_key INTEGER NOT NULL REFERENCES s7_mart.dim_date,
 product_key INTEGER NOT NULL REFERENCES s7_mart.dim_product,
 policy_key INTEGER NOT NULL REFERENCES s7_mart.dim_policy,
 participant_key INTEGER NOT NULL REFERENCES s7_mart.dim_participant,
 amount NUMERIC(15,2) NOT NULL CHECK(amount>0),UNIQUE(source_system,event_id));
CREATE TABLE s7_mart.fact_claim_payment (
 claim_payment_key INTEGER PRIMARY KEY,source_system TEXT NOT NULL,event_id INTEGER NOT NULL,
 payment_date_key INTEGER NOT NULL REFERENCES s7_mart.dim_date,
 product_key INTEGER NOT NULL REFERENCES s7_mart.dim_product,
 policy_key INTEGER NOT NULL REFERENCES s7_mart.dim_policy,
 participant_key INTEGER NOT NULL REFERENCES s7_mart.dim_participant,
 amount NUMERIC(15,2) NOT NULL CHECK(amount>0),UNIQUE(source_system,event_id));
-- Dua defect semantik mart disengaja: kontribusi event2 salah nilai,
-- klaim event2 salah bulan. Constraint struktural tetap aktif.
INSERT INTO s7_mart.fact_contribution_receipt VALUES
 (1001,'LAB7',1,20260110,11,21,101,100000),
 (1002,'LAB7',2,20260210,11,21,101,110000),
 (1003,'LAB7',3,20260310,11,21,101,100000),
 (1004,'LAB7',4,20260110,12,22,102,150000),
 (1005,'LAB7',5,20260210,12,22,102,150000),
 (1006,'LAB7',6,20260310,12,22,102,150000);
INSERT INTO s7_mart.fact_claim_payment VALUES
 (2001,'LAB7',1,20260125,11,21,101,1800000),
 (2002,'LAB7',2,20260205,11,21,101,900000),
 (2003,'LAB7',3,20260225,12,22,102,2500000);
-- Kontrol independen yang disetujui untuk batch ini, bukan dihitung dari mart.
CREATE TABLE s7_reference.expected_event (
 process TEXT NOT NULL,event_id INTEGER NOT NULL,product_code TEXT NOT NULL,
 event_date DATE NOT NULL,amount NUMERIC(15,2) NOT NULL,PRIMARY KEY(process,event_id));
INSERT INTO s7_reference.expected_event VALUES
 ('contribution',1,'PJ','2026-01-10',100000),('contribution',2,'PJ','2026-02-10',100000),
 ('contribution',3,'PJ','2026-03-10',100000),('contribution',4,'PP','2026-01-10',150000),
 ('contribution',5,'PP','2026-02-10',150000),('contribution',6,'PP','2026-03-10',150000),
 ('claim',1,'PJ','2026-01-25',1800000),('claim',2,'PJ','2026-03-05',900000),
 ('claim',3,'PP','2026-02-25',2500000);

CREATE VIEW s7_audit.contribution_variant_count AS
SELECT source_system,event_id,COUNT(*) AS variants FROM
 (SELECT DISTINCT source_system,event_id,policy_id,event_date,amount,UPPER(TRIM(status)) AS status FROM s7_source.contribution) v GROUP BY source_system,event_id;
CREATE VIEW s7_audit.classified_contribution AS
SELECT x.*,CASE
 WHEN x.source_system IS NULL OR TRIM(x.source_system)='' OR x.event_id IS NULL
  OR x.policy_id IS NULL OR x.event_date IS NULL OR x.amount IS NULL
  OR x.status IS NULL OR TRIM(x.status)='' THEN 'REJECT_REQUIRED'
 WHEN UPPER(TRIM(x.status)) NOT IN ('LUNAS','TERTUNDA','BATAL') THEN 'REJECT_STATUS'
 WHEN UPPER(TRIM(x.status))<>'LUNAS' THEN 'EXCLUDED_STATUS'
 WHEN x.amount<=0 THEN 'REJECT_AMOUNT'
 
 WHEN x.event_date<'2026-01-01' OR x.event_date>='2026-04-01' THEN 'EXCLUDED_PERIOD'
 WHEN p.policy_id IS NULL THEN 'REJECT_POLICY'
 WHEN vc.variants>1 THEN 'REJECT_DUP_CONFLICT'
 WHEN x.rn>1 THEN 'DUPLICATE_IDENTICAL'
 ELSE 'ELIGIBLE' END AS disposition
FROM (SELECT s.*,ROW_NUMBER() OVER(PARTITION BY source_system,event_id ORDER BY row_id) AS rn
 FROM s7_source.contribution s) x
LEFT JOIN s7_mart.dim_policy p ON p.policy_id=x.policy_id
LEFT JOIN s7_audit.contribution_variant_count vc ON vc.source_system=x.source_system AND vc.event_id=x.event_id;
CREATE VIEW s7_audit.eligible_contribution AS
SELECT * FROM s7_audit.classified_contribution WHERE disposition='ELIGIBLE';

CREATE VIEW s7_audit.claim_variant_count AS
SELECT source_system,event_id,COUNT(*) AS variants FROM
 (SELECT DISTINCT source_system,event_id,policy_id,submitted_date,paid_date,amount,UPPER(TRIM(status)) AS status FROM s7_source.claim) v GROUP BY source_system,event_id;
CREATE VIEW s7_audit.classified_claim AS
SELECT x.*,CASE
 WHEN x.source_system IS NULL OR TRIM(x.source_system)='' OR x.event_id IS NULL
  OR x.policy_id IS NULL OR x.submitted_date IS NULL OR (UPPER(TRIM(x.status))='DIBAYAR' AND (x.paid_date IS NULL OR x.amount IS NULL))
  OR x.status IS NULL OR TRIM(x.status)='' THEN 'REJECT_REQUIRED'
 WHEN UPPER(TRIM(x.status)) NOT IN ('DIBAYAR','DIAJUKAN','DISETUJUI','DITOLAK') THEN 'REJECT_STATUS'
 WHEN UPPER(TRIM(x.status))<>'DIBAYAR' THEN 'EXCLUDED_STATUS'
 WHEN x.amount<=0 THEN 'REJECT_AMOUNT'
 WHEN x.submitted_date IS NULL OR x.paid_date<x.submitted_date THEN 'REJECT_DATE_ORDER'
 WHEN x.paid_date<'2026-01-01' OR x.paid_date>='2026-04-01' THEN 'EXCLUDED_PERIOD'
 WHEN p.policy_id IS NULL THEN 'REJECT_POLICY'
 WHEN vc.variants>1 THEN 'REJECT_DUP_CONFLICT'
 WHEN x.rn>1 THEN 'DUPLICATE_IDENTICAL'
 ELSE 'ELIGIBLE' END AS disposition
FROM (SELECT s.*,ROW_NUMBER() OVER(PARTITION BY source_system,event_id ORDER BY row_id) AS rn
 FROM s7_source.claim s) x
LEFT JOIN s7_mart.dim_policy p ON p.policy_id=x.policy_id
LEFT JOIN s7_audit.claim_variant_count vc ON vc.source_system=x.source_system AND vc.event_id=x.event_id;
CREATE VIEW s7_audit.eligible_claim AS
SELECT * FROM s7_audit.classified_claim WHERE disposition='ELIGIBLE';
CREATE VIEW s7_audit.vw_dq_failures AS
SELECT 'DQ-001' AS rule_id,'source_contribution' AS location,row_id FROM (SELECT row_id FROM s7_source.contribution WHERE source_system IS NULL OR TRIM(source_system)='' OR event_id IS NULL OR policy_id IS NULL OR event_date IS NULL OR amount IS NULL OR status IS NULL OR TRIM(status)='') q
UNION ALL
SELECT 'DQ-002' AS rule_id,'source_contribution' AS location,row_id FROM (SELECT row_id FROM (SELECT row_id,COUNT(*) OVER(PARTITION BY source_system,event_id) AS n
 FROM s7_source.contribution WHERE source_system IS NOT NULL AND event_id IS NOT NULL) x WHERE n>1) q
UNION ALL
SELECT 'DQ-003' AS rule_id,'source_contribution' AS location,row_id FROM (SELECT row_id FROM s7_source.contribution WHERE amount IS NULL OR amount<=0) q
UNION ALL
SELECT 'DQ-004' AS rule_id,'source_contribution' AS location,row_id FROM (SELECT s.row_id FROM s7_source.contribution s LEFT JOIN s7_mart.dim_policy p ON p.policy_id=s.policy_id WHERE p.policy_id IS NULL) q
UNION ALL
SELECT 'DQ-005' AS rule_id,'source_contribution' AS location,row_id FROM (SELECT row_id FROM s7_source.contribution WHERE status IS NULL OR UPPER(TRIM(status)) NOT IN ('LUNAS','TERTUNDA','BATAL')) q
UNION ALL
SELECT 'DQ-001' AS rule_id,'source_claim' AS location,row_id FROM (SELECT row_id FROM s7_source.claim WHERE source_system IS NULL OR TRIM(source_system)='' OR event_id IS NULL OR policy_id IS NULL OR submitted_date IS NULL OR (UPPER(TRIM(status))='DIBAYAR' AND (paid_date IS NULL OR amount IS NULL)) OR status IS NULL OR TRIM(status)='') q
UNION ALL
SELECT 'DQ-002' AS rule_id,'source_claim' AS location,row_id FROM (SELECT row_id FROM (SELECT row_id,COUNT(*) OVER(PARTITION BY source_system,event_id) AS n
 FROM s7_source.claim WHERE source_system IS NOT NULL AND event_id IS NOT NULL) x WHERE n>1) q
UNION ALL
SELECT 'DQ-003' AS rule_id,'source_claim' AS location,row_id FROM (SELECT row_id FROM s7_source.claim WHERE UPPER(TRIM(status))='DIBAYAR' AND (amount IS NULL OR amount<=0)) q
UNION ALL
SELECT 'DQ-004' AS rule_id,'source_claim' AS location,row_id FROM (SELECT s.row_id FROM s7_source.claim s LEFT JOIN s7_mart.dim_policy p ON p.policy_id=s.policy_id WHERE p.policy_id IS NULL) q
UNION ALL
SELECT 'DQ-005' AS rule_id,'source_claim' AS location,row_id FROM (SELECT row_id FROM s7_source.claim WHERE status IS NULL OR UPPER(TRIM(status)) NOT IN ('DIBAYAR','DIAJUKAN','DISETUJUI','DITOLAK')) q
UNION ALL
SELECT 'DQ-006' AS rule_id,'source_claim' AS location,row_id FROM (SELECT row_id FROM s7_source.claim WHERE UPPER(TRIM(status))='DIBAYAR' AND submitted_date IS NOT NULL AND paid_date<submitted_date) q
UNION ALL
SELECT 'DQ-007' AS rule_id,'mart_contribution' AS location,row_id FROM (SELECT f.contribution_key AS row_id FROM s7_mart.fact_contribution_receipt f JOIN s7_reference.expected_event e ON e.process='contribution' AND e.event_id=f.event_id WHERE f.source_system='LAB7' AND f.amount<>e.amount) q
UNION ALL
SELECT 'DQ-008' AS rule_id,'mart_claim' AS location,row_id FROM (SELECT f.claim_payment_key AS row_id FROM s7_mart.fact_claim_payment f JOIN s7_mart.dim_date d ON d.date_key=f.payment_date_key JOIN s7_reference.expected_event e ON e.process='claim' AND e.event_id=f.event_id WHERE f.source_system='LAB7' AND d.calendar_date<>e.event_date) q;
