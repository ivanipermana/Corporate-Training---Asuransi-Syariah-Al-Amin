-- PostgreSQL. Jalankan setelah initial load, rerun, dan delta. Semua query read only.
-- R1 manifest source vs staged: expected_rows harus sama staged_rows.
SELECT m.table_name,m.expected_rows,x.staged_rows,x.staged_rows-m.expected_rows AS difference
FROM s6_staging.manifest m JOIN (
 SELECT 'product' AS t,COUNT(*) AS staged_rows FROM s6_staging.product UNION ALL
 SELECT 'participant',COUNT(*) FROM s6_staging.participant UNION ALL
 SELECT 'policy',COUNT(*) FROM s6_staging.policy UNION ALL
 SELECT 'contribution',COUNT(*) FROM s6_staging.contribution UNION ALL
 SELECT 'claim',COUNT(*) FROM s6_staging.claim) x ON x.t=m.table_name ORDER BY m.table_name;
-- Raw SUM staging harus cocok dengan query raw source MariaDB pada snapshot sama.
SELECT COUNT(*) AS raw_rows,SUM(amount) AS raw_amount FROM s6_staging.contribution;
SELECT COUNT(*) AS raw_rows,SUM(paid_amount) AS raw_amount FROM s6_staging.claim;

-- R2 contribution: setiap raw baris mendapat tepat satu disposition; jumlah = raw count.
SELECT disposition,COUNT(*) AS n,SUM(amount) AS rupiah
FROM s6_staging.classified_contribution GROUP BY disposition ORDER BY disposition;
-- R3 eligible source (staged snapshot) vs fact; difference harus nol.
SELECT s.n AS source_eligible_rows,t.n AS target_rows,t.n-s.n AS row_difference,
 s.a AS source_amount,t.a AS target_amount,t.a-s.a AS amount_difference
FROM (SELECT COUNT(*) AS n,COALESCE(SUM(amount),0) AS a
 FROM s6_staging.classified_contribution WHERE disposition='ELIGIBLE') s
CROSS JOIN (SELECT COUNT(*) AS n,COALESCE(SUM(amount),0) AS a
 FROM s6_mart.fact_contribution_receipt WHERE source_system='LAB6') t;
-- R4 mapping hilang: jangan menganggap INNER JOIN membuktikan semua data terangkut.
SELECT x.event_id FROM s6_staging.classified_contribution x
LEFT JOIN s6_staging.valid_policy p ON p.policy_id=x.policy_id
LEFT JOIN s6_mart.dim_product pr ON pr.product_code=p.product_code
LEFT JOIN s6_mart.dim_policy po ON po.policy_id=p.policy_id
LEFT JOIN s6_mart.dim_participant pe ON pe.participant_id=p.participant_id
LEFT JOIN s6_mart.dim_date d ON d.calendar_date=x.event_date
WHERE x.disposition='ELIGIBLE' AND (pr.product_key IS NULL OR po.policy_key IS NULL
 OR pe.participant_key IS NULL OR d.date_key IS NULL);
-- R5 keunikan event: kosong.
SELECT source_system,event_id,COUNT(*) FROM s6_mart.fact_contribution_receipt
GROUP BY source_system,event_id HAVING COUNT(*)>1;
-- R6 selisih per event: kosong; NULL, amount, tanggal, dan key ikut diperiksa.
SELECT x.event_id FROM s6_staging.classified_contribution x
LEFT JOIN s6_staging.valid_policy p ON p.policy_id=x.policy_id
LEFT JOIN s6_mart.dim_product pr ON pr.product_code=p.product_code
LEFT JOIN s6_mart.dim_policy po ON po.policy_id=p.policy_id
LEFT JOIN s6_mart.dim_participant pe ON pe.participant_id=p.participant_id
LEFT JOIN s6_mart.dim_date d ON d.calendar_date=x.event_date
LEFT JOIN s6_mart.fact_contribution_receipt f ON f.source_system='LAB6' AND f.event_id=x.event_id
WHERE x.disposition='ELIGIBLE' AND (f.event_id IS NULL OR f.amount<>x.amount
 OR f.contribution_date_key<>d.date_key OR f.product_key<>pr.product_key
 OR f.policy_key<>po.policy_key OR f.participant_key<>pe.participant_key);
-- R7 target tak memiliki eligible source: kosong.
SELECT f.event_id FROM s6_mart.fact_contribution_receipt f
WHERE f.source_system='LAB6' AND NOT EXISTS(SELECT 1 FROM s6_staging.classified_contribution x
 WHERE x.event_id=f.event_id AND x.disposition='ELIGIBLE');
-- R8 laporan per bulan dan produk; tidak join dua fact langsung.
SELECT SUBSTRING(CAST(d.calendar_date AS TEXT),1,7) AS bulan,p.product_code,
 COUNT(*) AS n,SUM(f.amount) AS rupiah FROM s6_mart.fact_contribution_receipt f
JOIN s6_mart.dim_date d ON d.date_key=f.contribution_date_key
JOIN s6_mart.dim_product p ON p.product_key=f.product_key
WHERE f.source_system='LAB6'
GROUP BY SUBSTRING(CAST(d.calendar_date AS TEXT),1,7),p.product_code
ORDER BY bulan,p.product_code;

-- R2 claim: setiap raw baris mendapat tepat satu disposition; jumlah = raw count.
SELECT disposition,COUNT(*) AS n,SUM(paid_amount) AS rupiah
FROM s6_staging.classified_claim GROUP BY disposition ORDER BY disposition;
-- R3 eligible source (staged snapshot) vs fact; difference harus nol.
SELECT s.n AS source_eligible_rows,t.n AS target_rows,t.n-s.n AS row_difference,
 s.a AS source_amount,t.a AS target_amount,t.a-s.a AS amount_difference
FROM (SELECT COUNT(*) AS n,COALESCE(SUM(paid_amount),0) AS a
 FROM s6_staging.classified_claim WHERE disposition='ELIGIBLE') s
CROSS JOIN (SELECT COUNT(*) AS n,COALESCE(SUM(amount),0) AS a
 FROM s6_mart.fact_claim_payment WHERE source_system='LAB6') t;
-- R4 mapping hilang: jangan menganggap INNER JOIN membuktikan semua data terangkut.
SELECT x.event_id FROM s6_staging.classified_claim x
LEFT JOIN s6_staging.valid_policy p ON p.policy_id=x.policy_id
LEFT JOIN s6_mart.dim_product pr ON pr.product_code=p.product_code
LEFT JOIN s6_mart.dim_policy po ON po.policy_id=p.policy_id
LEFT JOIN s6_mart.dim_participant pe ON pe.participant_id=p.participant_id
LEFT JOIN s6_mart.dim_date d ON d.calendar_date=x.paid_date
WHERE x.disposition='ELIGIBLE' AND (pr.product_key IS NULL OR po.policy_key IS NULL
 OR pe.participant_key IS NULL OR d.date_key IS NULL);
-- R5 keunikan event: kosong.
SELECT source_system,event_id,COUNT(*) FROM s6_mart.fact_claim_payment
GROUP BY source_system,event_id HAVING COUNT(*)>1;
-- R6 selisih per event: kosong; NULL, amount, tanggal, dan key ikut diperiksa.
SELECT x.event_id FROM s6_staging.classified_claim x
LEFT JOIN s6_staging.valid_policy p ON p.policy_id=x.policy_id
LEFT JOIN s6_mart.dim_product pr ON pr.product_code=p.product_code
LEFT JOIN s6_mart.dim_policy po ON po.policy_id=p.policy_id
LEFT JOIN s6_mart.dim_participant pe ON pe.participant_id=p.participant_id
LEFT JOIN s6_mart.dim_date d ON d.calendar_date=x.paid_date
LEFT JOIN s6_mart.fact_claim_payment f ON f.source_system='LAB6' AND f.event_id=x.event_id
WHERE x.disposition='ELIGIBLE' AND (f.event_id IS NULL OR f.amount<>x.paid_amount
 OR f.payment_date_key<>d.date_key OR f.product_key<>pr.product_key
 OR f.policy_key<>po.policy_key OR f.participant_key<>pe.participant_key);
-- R7 target tak memiliki eligible source: kosong.
SELECT f.event_id FROM s6_mart.fact_claim_payment f
WHERE f.source_system='LAB6' AND NOT EXISTS(SELECT 1 FROM s6_staging.classified_claim x
 WHERE x.event_id=f.event_id AND x.disposition='ELIGIBLE');
-- R8 laporan per bulan dan produk; tidak join dua fact langsung.
SELECT SUBSTRING(CAST(d.calendar_date AS TEXT),1,7) AS bulan,p.product_code,
 COUNT(*) AS n,SUM(f.amount) AS rupiah FROM s6_mart.fact_claim_payment f
JOIN s6_mart.dim_date d ON d.date_key=f.payment_date_key
JOIN s6_mart.dim_product p ON p.product_key=f.product_key
WHERE f.source_system='LAB6'
GROUP BY SUBSTRING(CAST(d.calendar_date AS TEXT),1,7),p.product_code
ORDER BY bulan,p.product_code;

-- R9 rejected rows untuk diagnosis, bukan dibuang tanpa catatan.
SELECT event_id,disposition FROM s6_staging.classified_contribution WHERE disposition LIKE 'REJECT%';
SELECT event_id,disposition FROM s6_staging.classified_claim WHERE disposition LIKE 'REJECT%';
