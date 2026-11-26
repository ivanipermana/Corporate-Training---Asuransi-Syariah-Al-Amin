-- READ ONLY. Jalankan sebelum mengimpor dan sesudah refresh.
SELECT 'contribution' AS objek,month_key,product_code,COUNT(*) AS n
FROM fp_reporting.vw_contribution_kpi GROUP BY month_key,product_code HAVING COUNT(*)>1
UNION ALL
SELECT 'claims',month_key,product_code,COUNT(*) FROM fp_reporting.vw_claims_kpi
GROUP BY month_key,product_code HAVING COUNT(*)>1;
-- Hasil harus kosong. Satu kode produk harus mempunyai satu label konsisten.
SELECT product_code,COUNT(DISTINCT product_name) AS labels FROM (
 SELECT product_code,product_name FROM fp_reporting.vw_contribution_kpi
 UNION SELECT product_code,product_name FROM fp_reporting.vw_claims_kpi) x
GROUP BY product_code HAVING COUNT(DISTINCT product_name)>1;
SELECT * FROM fp_reporting.vw_contribution_kpi ORDER BY month_key,product_code;
SELECT * FROM fp_reporting.vw_claims_kpi ORDER BY month_key,product_code;
-- Catat hasil source/ELT/DQ terpisah. Lolos pada reporting view tidak membuktikan
-- source-to-target pipeline sudah berjalan atau source sudah bebas exception.
