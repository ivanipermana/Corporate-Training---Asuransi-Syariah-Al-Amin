-- READ ONLY. Default memakai salinan sumber khusus Sesi 2.
-- Jika memakai database Sesi 1, ganti USE saja menjadi lab_asuransi_konseptual.
USE lab_asuransi_sesi2_sumber;
SELECT VERSION() AS versi_mariadb, DATABASE() AS database_aktif;
SHOW TABLES;
DESCRIBE polis;
DESCRIBE klaim;
SHOW CREATE TABLE polis;
SHOW CREATE TABLE klaim;
-- Ulangi DESCRIBE / SHOW CREATE untuk produk, peserta, kontribusi.

-- Satu baris metadata per kolom: seharusnya total 23 baris pada dataset lab.
SELECT TABLE_NAME, ORDINAL_POSITION, COLUMN_NAME, COLUMN_TYPE,
       IS_NULLABLE, COLUMN_KEY, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- Empat foreign key pada sumber.
SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME,
       REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- Tipe constraint; bedakan yang tersedia di sumber dan yang baru diusulkan.
SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, CONSTRAINT_TYPE, CONSTRAINT_NAME;

SELECT * FROM polis ORDER BY polis_id LIMIT 5;
SELECT * FROM kontribusi WHERE polis_id = 1 ORDER BY kontribusi_id;
SELECT * FROM klaim WHERE polis_id = 1 ORDER BY klaim_id;
SELECT status_kontribusi, COUNT(*) AS jumlah FROM kontribusi GROUP BY status_kontribusi;
SELECT status_klaim, COUNT(*) AS jumlah FROM klaim GROUP BY status_klaim;
