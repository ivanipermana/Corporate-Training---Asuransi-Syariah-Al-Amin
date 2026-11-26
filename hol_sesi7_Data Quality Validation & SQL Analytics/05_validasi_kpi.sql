-- V1 contribution: fact vs view total. Nol belum membuktikan tanggal sumber benar.
SELECT f.n AS fact_events,v.n AS view_events,v.n-f.n AS count_difference,
 f.a AS fact_amount,v.a AS view_amount,v.a-f.a AS amount_difference
FROM (SELECT COUNT(*) AS n,COALESCE(SUM(f.amount),0) AS a FROM s7_mart.fact_contribution_receipt f
 JOIN s7_mart.dim_date d ON d.date_key=f.contribution_date_key
 WHERE f.source_system='LAB7' AND d.calendar_date>='2026-01-01' AND d.calendar_date<'2026-04-01') f
CROSS JOIN (SELECT COALESCE(SUM(event_count),0) AS n,COALESCE(SUM(total_amount),0) AS a
 FROM s7_mart.vw_contribution_kpi) v;
-- V2 per product-month terhadap control independen. Hasil wajib kosong untuk PASS.
WITH expected AS (
 SELECT SUBSTRING(CAST(event_date AS TEXT),1,7) AS month_key,product_code,
 COUNT(*) AS n,SUM(amount) AS a FROM s7_reference.expected_event
 WHERE process='contribution' GROUP BY SUBSTRING(CAST(event_date AS TEXT),1,7),product_code
), keys AS (SELECT month_key,product_code FROM expected UNION
 SELECT month_key,product_code FROM s7_mart.vw_contribution_kpi)
SELECT k.month_key,k.product_code,COALESCE(e.n,0) AS expected_count,
 COALESCE(v.event_count,0) AS actual_count,COALESCE(e.a,0) AS expected_amount,
 COALESCE(v.total_amount,0) AS actual_amount
FROM keys k LEFT JOIN expected e ON e.month_key=k.month_key AND e.product_code=k.product_code
LEFT JOIN s7_mart.vw_contribution_kpi v ON v.month_key=k.month_key AND v.product_code=k.product_code
WHERE COALESCE(e.n,0)<>COALESCE(v.event_count,0) OR COALESCE(e.a,0)<>COALESCE(v.total_amount,0)
ORDER BY k.month_key,k.product_code;
-- V3 keunikan grain view: kosong.
SELECT month_key,product_code,COUNT(*) FROM s7_mart.vw_contribution_kpi
GROUP BY month_key,product_code HAVING COUNT(*)>1;
SELECT * FROM s7_mart.vw_contribution_kpi ORDER BY month_key,product_code;

-- V1 claim: fact vs view total. Nol belum membuktikan tanggal sumber benar.
SELECT f.n AS fact_events,v.n AS view_events,v.n-f.n AS count_difference,
 f.a AS fact_amount,v.a AS view_amount,v.a-f.a AS amount_difference
FROM (SELECT COUNT(*) AS n,COALESCE(SUM(f.amount),0) AS a FROM s7_mart.fact_claim_payment f
 JOIN s7_mart.dim_date d ON d.date_key=f.payment_date_key
 WHERE f.source_system='LAB7' AND d.calendar_date>='2026-01-01' AND d.calendar_date<'2026-04-01') f
CROSS JOIN (SELECT COALESCE(SUM(event_count),0) AS n,COALESCE(SUM(total_amount),0) AS a
 FROM s7_mart.vw_claims_kpi) v;
-- V2 per product-month terhadap control independen. Hasil wajib kosong untuk PASS.
WITH expected AS (
 SELECT SUBSTRING(CAST(event_date AS TEXT),1,7) AS month_key,product_code,
 COUNT(*) AS n,SUM(amount) AS a FROM s7_reference.expected_event
 WHERE process='claim' GROUP BY SUBSTRING(CAST(event_date AS TEXT),1,7),product_code
), keys AS (SELECT month_key,product_code FROM expected UNION
 SELECT month_key,product_code FROM s7_mart.vw_claims_kpi)
SELECT k.month_key,k.product_code,COALESCE(e.n,0) AS expected_count,
 COALESCE(v.event_count,0) AS actual_count,COALESCE(e.a,0) AS expected_amount,
 COALESCE(v.total_amount,0) AS actual_amount
FROM keys k LEFT JOIN expected e ON e.month_key=k.month_key AND e.product_code=k.product_code
LEFT JOIN s7_mart.vw_claims_kpi v ON v.month_key=k.month_key AND v.product_code=k.product_code
WHERE COALESCE(e.n,0)<>COALESCE(v.event_count,0) OR COALESCE(e.a,0)<>COALESCE(v.total_amount,0)
ORDER BY k.month_key,k.product_code;
-- V3 keunikan grain view: kosong.
SELECT month_key,product_code,COUNT(*) FROM s7_mart.vw_claims_kpi
GROUP BY month_key,product_code HAVING COUNT(*)>1;
SELECT * FROM s7_mart.vw_claims_kpi ORDER BY month_key,product_code;
