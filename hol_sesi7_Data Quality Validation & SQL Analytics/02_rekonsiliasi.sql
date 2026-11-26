-- contribution: raw bridge, setiap baris memiliki satu disposition utama.
SELECT disposition,COUNT(*) AS n,SUM(amount) AS amount_known,
 SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS null_amount_rows
FROM s7_audit.classified_contribution GROUP BY disposition ORDER BY disposition;
-- Eligible source vs target, periode Jan-Mar sama, source_system LAB7.
SELECT s.n AS source_rows,f.n AS target_rows,f.n-s.n AS row_difference,
 s.a AS source_amount,f.a AS target_amount,f.a-s.a AS amount_difference
FROM (SELECT COUNT(*) AS n,COALESCE(SUM(amount),0) AS a FROM s7_audit.eligible_contribution) s
CROSS JOIN (SELECT COUNT(*) AS n,COALESCE(SUM(amount),0) AS a
 FROM s7_mart.fact_contribution_receipt WHERE source_system='LAB7') f;
-- Per-event mismatch terhadap reference independen, termasuk product dan tanggal.
SELECT e.event_id,e.amount AS expected_amount,f.amount AS target_amount,
 e.event_date AS expected_date,d.calendar_date AS target_date,
 e.product_code AS expected_product,p.product_code AS target_product
FROM s7_reference.expected_event e
LEFT JOIN s7_mart.fact_contribution_receipt f ON f.event_id=e.event_id AND f.source_system='LAB7'
LEFT JOIN s7_mart.dim_date d ON d.date_key=f.contribution_date_key
LEFT JOIN s7_mart.dim_product p ON p.product_key=f.product_key
WHERE e.process='contribution' AND (f.event_id IS NULL OR f.amount<>e.amount
 OR d.calendar_date<>e.event_date OR p.product_code<>e.product_code);
-- Target extra events: kosong.
SELECT f.event_id FROM s7_mart.fact_contribution_receipt f WHERE f.source_system='LAB7'
AND NOT EXISTS(SELECT 1 FROM s7_reference.expected_event e
 WHERE e.process='contribution' AND e.event_id=f.event_id);

-- claim: raw bridge, setiap baris memiliki satu disposition utama.
SELECT disposition,COUNT(*) AS n,SUM(amount) AS amount_known,
 SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS null_amount_rows
FROM s7_audit.classified_claim GROUP BY disposition ORDER BY disposition;
-- Eligible source vs target, periode Jan-Mar sama, source_system LAB7.
SELECT s.n AS source_rows,f.n AS target_rows,f.n-s.n AS row_difference,
 s.a AS source_amount,f.a AS target_amount,f.a-s.a AS amount_difference
FROM (SELECT COUNT(*) AS n,COALESCE(SUM(amount),0) AS a FROM s7_audit.eligible_claim) s
CROSS JOIN (SELECT COUNT(*) AS n,COALESCE(SUM(amount),0) AS a
 FROM s7_mart.fact_claim_payment WHERE source_system='LAB7') f;
-- Per-event mismatch terhadap reference independen, termasuk product dan tanggal.
SELECT e.event_id,e.amount AS expected_amount,f.amount AS target_amount,
 e.event_date AS expected_date,d.calendar_date AS target_date,
 e.product_code AS expected_product,p.product_code AS target_product
FROM s7_reference.expected_event e
LEFT JOIN s7_mart.fact_claim_payment f ON f.event_id=e.event_id AND f.source_system='LAB7'
LEFT JOIN s7_mart.dim_date d ON d.date_key=f.payment_date_key
LEFT JOIN s7_mart.dim_product p ON p.product_key=f.product_key
WHERE e.process='claim' AND (f.event_id IS NULL OR f.amount<>e.amount
 OR d.calendar_date<>e.event_date OR p.product_code<>e.product_code);
-- Target extra events: kosong.
SELECT f.event_id FROM s7_mart.fact_claim_payment f WHERE f.source_system='LAB7'
AND NOT EXISTS(SELECT 1 FROM s7_reference.expected_event e
 WHERE e.process='claim' AND e.event_id=f.event_id);
