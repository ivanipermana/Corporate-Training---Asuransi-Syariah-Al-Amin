-- MariaDB. Khusus fixture Sesi 6; replay menghasilkan keadaan sama.
USE lab_asuransi_sesi6_source;
UPDATE contribution SET amount=110000 WHERE event_id=2;
INSERT INTO contribution VALUES (10,2,'2026-03-20',125000,'LUNAS')
 ON DUPLICATE KEY UPDATE amount=125000;
UPDATE claim SET paid_amount=950000 WHERE event_id=2;
INSERT INTO claim VALUES (6,2,'2026-03-15','2026-03-25',400000,'DIBAYAR')
 ON DUPLICATE KEY UPDATE paid_amount=400000;
-- Source sekarang contribution10 claim6; jalankan lagi profiling source.
