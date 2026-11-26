-- OPSI B: Sesi6 baseline yang dipilih tim (awal atau sesudah delta).
-- Jalankan SATU adapter pada namespace fp_reporting baru; jangan jalankan sesudah opsi A.
-- SQL ELT dan rekonsiliasi Sesi6 harus sudah lolos; jangan menggabungkan nilai baseline.
CREATE SCHEMA fp_reporting;
CREATE VIEW fp_reporting.vw_contribution_kpi AS
SELECT SUBSTRING(CAST(d.calendar_date AS TEXT),1,7) AS month_key,
 p.product_code,p.product_name,COUNT(*) AS event_count,SUM(f.amount) AS total_amount
FROM s6_mart.fact_contribution_receipt f JOIN s6_mart.dim_date d ON d.date_key=f.contribution_date_key
JOIN s6_mart.dim_product p ON p.product_key=f.product_key
WHERE f.source_system='LAB6' AND d.calendar_date>='2026-01-01' AND d.calendar_date<'2026-04-01'
GROUP BY SUBSTRING(CAST(d.calendar_date AS TEXT),1,7),p.product_code,p.product_name;
CREATE VIEW fp_reporting.vw_claims_kpi AS
SELECT SUBSTRING(CAST(d.calendar_date AS TEXT),1,7) AS month_key,
 p.product_code,p.product_name,COUNT(*) AS event_count,SUM(f.amount) AS total_amount
FROM s6_mart.fact_claim_payment f JOIN s6_mart.dim_date d ON d.date_key=f.payment_date_key
JOIN s6_mart.dim_product p ON p.product_key=f.product_key
WHERE f.source_system='LAB6' AND d.calendar_date>='2026-01-01' AND d.calendar_date<'2026-04-01'
GROUP BY SUBSTRING(CAST(d.calendar_date AS TEXT),1,7),p.product_code,p.product_name;
