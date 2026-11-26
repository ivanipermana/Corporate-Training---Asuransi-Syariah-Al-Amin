-- READ ONLY. Samakan filter ini dengan slicer/page/report/visual filters Power BI.
-- YYYY-MM inklusif pada kedua batas. product_code NULL = semua produk.
WITH params AS (
 SELECT '2026-01' AS month_from,'2026-03' AS month_to,CAST(NULL AS TEXT) AS product_code
), c AS (
 SELECT COALESCE(SUM(v.total_amount),0) AS amount,COALESCE(SUM(v.event_count),0) AS n
 FROM fp_reporting.vw_contribution_kpi v CROSS JOIN params p
 WHERE v.month_key>=p.month_from AND v.month_key<=p.month_to
 AND (p.product_code IS NULL OR v.product_code=p.product_code)
), k AS (
 SELECT COALESCE(SUM(v.total_amount),0) AS amount,COALESCE(SUM(v.event_count),0) AS n
 FROM fp_reporting.vw_claims_kpi v CROSS JOIN params p
 WHERE v.month_key>=p.month_from AND v.month_key<=p.month_to
 AND (p.product_code IS NULL OR v.product_code=p.product_code)
)
SELECT c.amount AS total_kontribusi_lunas,k.amount AS total_klaim_dibayar,
 1.0*k.amount/NULLIF(c.amount,0) AS rasio_desimal,
 c.n AS jumlah_transaksi_kontribusi,k.n AS jumlah_klaim_dibayar FROM c CROSS JOIN k;
-- Ratio 0.048 diformat 4.8%, bukan angka yang sudah dikalikan100 dalam DAX.
-- Penyebut0 -> NULL di SQL, BLANK di DAX. Jangan mengubahnya menjadi0%.
