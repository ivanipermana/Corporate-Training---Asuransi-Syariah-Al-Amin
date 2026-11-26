-- Read only. Jalankan setelah setup fasilitator. Simpan bukti sebelum koreksi.
SELECT current_database(),version();
-- Contoh completeness langsung; view failures menggabungkan semua aturan.
SELECT row_id,event_id FROM s7_source.contribution
WHERE event_id IS NULL OR policy_id IS NULL OR event_date IS NULL OR amount IS NULL;
-- Semua record gagal per aturan. row_id selalu digabung dengan location.
SELECT rule_id,location,row_id FROM s7_audit.vw_dq_failures ORDER BY rule_id,location,row_id;
SELECT rule_id,COUNT(*) AS failed_records FROM s7_audit.vw_dq_failures GROUP BY rule_id ORDER BY rule_id;
-- Satu record dapat gagal beberapa aturan. Hitung union record, bukan SUM count aturan.
SELECT COUNT(*) AS distinct_failed_records FROM
 (SELECT DISTINCT location,row_id FROM s7_audit.vw_dq_failures) u;
-- Duplicate: affected rows dan excess rows berbeda.
SELECT source_system,event_id,COUNT(*) AS affected_rows,COUNT(*)-1 AS excess_rows
FROM s7_source.contribution WHERE event_id IS NOT NULL
GROUP BY source_system,event_id HAVING COUNT(*)>1;
-- TODO peserta: tulis query Anda sendiri untuk DQ-003 atau DQ-004,
-- kemudian bandingkan record ID dengan hasil vw_dq_failures.
