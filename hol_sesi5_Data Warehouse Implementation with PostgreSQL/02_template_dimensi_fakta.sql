-- AKTIVITAS 2. Semua dimensi harus tersedia sebelum fact dibuat.
-- Susunan: date, product, participant, policy, fact contribution, fact claim.
-- Key diisi eksplisit pada prototipe. ETL produksi perlu strategi pembentukan SK.
CREATE TABLE mart.dim_date (
 date_key INTEGER PRIMARY KEY,
 calendar_date DATE NOT NULL UNIQUE,
 month_number INTEGER NOT NULL CHECK (month_number BETWEEN 1 AND 12),
 year_number INTEGER NOT NULL
);

CREATE TABLE mart.dim_product (
 product_key INTEGER PRIMARY KEY,
 source_system TEXT NOT NULL,
 produk_id INTEGER NOT NULL,
 nama_produk TEXT NOT NULL,
 UNIQUE (source_system, produk_id)
);

CREATE TABLE mart.dim_participant (
 participant_key INTEGER PRIMARY KEY,
 source_system TEXT NOT NULL,
 peserta_id INTEGER NOT NULL,
 nama_peserta TEXT NOT NULL,
 kota TEXT NOT NULL,
 valid_from DATE NOT NULL,
 valid_to DATE,
 is_current BOOLEAN NOT NULL,
 UNIQUE (source_system, peserta_id, valid_from),
 CHECK (valid_to IS NULL OR valid_to > valid_from),
 CHECK ((is_current AND valid_to IS NULL) OR
        (NOT is_current AND valid_to IS NOT NULL))
);
CREATE UNIQUE INDEX uq_participant_current
 ON mart.dim_participant(source_system,peserta_id) WHERE is_current;

-- TODO B: tulis CREATE TABLE mart.dim_policy di bawah ini sebelum fact contribution.
-- policy_key INTEGER PK; source_system TEXT NOT NULL; polis_id INTEGER NOT NULL;
-- nomor_polis TEXT NOT NULL; tanggal_mulai dan tanggal_akhir DATE NOT NULL.
-- Tambahkan UNIQUE(source_system,polis_id), UNIQUE(source_system,nomor_polis),
-- CHECK(tanggal_akhir >= tanggal_mulai).

CREATE TABLE mart.fact_contribution_receipt (
 contribution_key BIGINT PRIMARY KEY,
 source_system TEXT NOT NULL,
 kontribusi_id BIGINT NOT NULL,
 contribution_date_key INTEGER NOT NULL REFERENCES mart.dim_date(date_key),
 product_key INTEGER NOT NULL REFERENCES mart.dim_product(product_key),
 policy_key INTEGER NOT NULL REFERENCES mart.dim_policy(policy_key),
 participant_key INTEGER NOT NULL REFERENCES mart.dim_participant(participant_key),
 jumlah_kontribusi NUMERIC(15,2) NOT NULL CHECK (jumlah_kontribusi > 0),
 transaction_count INTEGER NOT NULL DEFAULT 1 CHECK (transaction_count = 1),
 UNIQUE (source_system, kontribusi_id)
);

-- TODO C: buat mart.fact_claim_payment mengikuti pola fact contribution.
-- PK claim_payment_key BIGINT; source_system TEXT NOT NULL; klaim_id BIGINT NOT NULL.
-- Empat FK NOT NULL: payment_date_key -> dim_date(date_key),
-- product_key -> dim_product, policy_key -> dim_policy,
-- participant_key -> dim_participant (masing-masing PK dengan nama sama).
-- nilai_bayar NUMERIC(15,2) NOT NULL CHECK > 0;
-- paid_claim_count INTEGER NOT NULL DEFAULT 1 CHECK = 1.
-- UNIQUE(source_system,klaim_id). Ini valid hanya untuk fixture satu pembayaran per klaim.
