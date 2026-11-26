-- OPSI A: Sesi7 yang SUDAH dikoreksi dan dua view KPI SUDAH tervalidasi.
-- Jalankan satu adapter saja pada database lab. fp_reporting belum boleh ada.
-- Ini adapter reporting; tidak membuktikan integrasi source-to-warehouse.
CREATE SCHEMA fp_reporting;
CREATE VIEW fp_reporting.vw_contribution_kpi AS
SELECT month_key,product_code,product_name,event_count,total_amount
FROM s7_mart.vw_contribution_kpi;
CREATE VIEW fp_reporting.vw_claims_kpi AS
SELECT month_key,product_code,product_name,event_count,total_amount
FROM s7_mart.vw_claims_kpi;
