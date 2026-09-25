-- ============================================================
-- 02_load_and_clean.sql
-- Load raw CSVs into staging, then build a cleaned view.
-- ============================================================

-- ---- SQLite loading (run from the sqlite3 CLI) ----
-- .mode csv
-- .import data/raw/diabetic_data.csv encounters_raw
-- (IDs_mapping.csv has three stacked tables separated by blank lines —
--  split it into three files first, e.g. with a small pandas script,
--  or import manually into the three *_map tables.)

-- ---- Cleaned staging view ----
-- '?' is the dataset's missing-value sentinel. Convert to NULL and
-- apply the clinical exclusion rule (hospice / expired patients cannot
-- be readmitted, so they are removed from the modeling population).

DROP VIEW IF EXISTS encounters_clean;

CREATE VIEW encounters_clean AS
SELECT
    encounter_id,
    patient_nbr,
    NULLIF(race, '?')            AS race,
    gender,
    age,
    NULLIF(weight, '?')          AS weight,
    admission_type_id,
    discharge_disposition_id,
    admission_source_id,
    time_in_hospital,
    NULLIF(payer_code, '?')      AS payer_code,
    NULLIF(medical_specialty, '?') AS medical_specialty,
    num_lab_procedures,
    num_procedures,
    num_medications,
    number_outpatient,
    number_emergency,
    number_inpatient,
    NULLIF(diag_1, '?')          AS diag_1,
    NULLIF(diag_2, '?')          AS diag_2,
    NULLIF(diag_3, '?')          AS diag_3,
    number_diagnoses,
    max_glu_serum,
    a1cresult,
    change_in_meds,
    diabetes_med,
    readmitted,
    CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END AS readmitted_30d
FROM encounters
WHERE discharge_disposition_id NOT IN (
    11, 13, 14, 19, 20, 21   -- expired / hospice codes — see discharge_disposition_map
);

-- Sanity check row counts after exclusion
-- SELECT COUNT(*) AS total_raw FROM encounters;
-- SELECT COUNT(*) AS total_clean FROM encounters_clean;
