-- Setelah data mart diperiksa. Schema s7_mart adalah mart khusus Sesi7.
-- Nama pada slide mart.vw_* disesuaikan menjadi s7_mart.vw_*.
-- Grain view: satu product_code per month_key (YYYY-MM), bukan satu event.
CREATE VIEW s7_mart.vw_contribution_kpi AS
SELECT SUBSTRING(CAST(d.calendar_date AS TEXT),1,7) AS month_key,
 p.product_code,p.product_name,COUNT(*) AS event_count,
 SUM(f.amount) AS total_amount
FROM s7_mart.fact_contribution_receipt f
JOIN s7_mart.dim_date d ON d.date_key=f.contribution_date_key
JOIN s7_mart.dim_product p ON p.product_key=f.product_key
WHERE f.source_system='LAB7'
 AND d.calendar_date>='2026-01-01' AND d.calendar_date<'2026-04-01'
GROUP BY SUBSTRING(CAST(d.calendar_date AS TEXT),1,7),p.product_code,p.product_name;
-- TODO: buat s7_mart.vw_claims_kpi mengikuti contoh kontribusi.
-- Pakai fact_claim_payment, FK payment_date_key, dim_date dan dim_product.
-- Kolom: month_key, product_code, product_name, event_count, total_amount.
-- Filter source_system LAB7, periode Jan-Mar2026; COUNT(*) dan SUM(amount).
-- Tidak join kedua fact langsung. Semua fact klaim pada fixture adalah dibayar.
-- CREATE VIEW sekali. Untuk revisi, gunakan CREATE OR REPLACE VIEW dengan kolom sama.
