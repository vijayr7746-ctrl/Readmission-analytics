-- ============================================================
-- 01_schema.sql
-- Normalized schema for the diabetes readmissions dataset.
-- Works on SQLite and PostgreSQL (minor type tweaks noted).
-- ============================================================

DROP TABLE IF EXISTS encounters;
DROP TABLE IF EXISTS admission_type_map;
DROP TABLE IF EXISTS discharge_disposition_map;
DROP TABLE IF EXISTS admission_source_map;

-- Lookup tables (from IDs_mapping.csv, which ships with the dataset —
-- it contains three stacked mapping tables separated by blank rows;
-- split them out when loading, see 02_load_and_clean.sql)
CREATE TABLE admission_type_map (
    admission_type_id   INTEGER PRIMARY KEY,
    description          TEXT
);

CREATE TABLE discharge_disposition_map (
    discharge_disposition_id INTEGER PRIMARY KEY,
    description                TEXT
);

CREATE TABLE admission_source_map (
    admission_source_id INTEGER PRIMARY KEY,
    description           TEXT
);

-- Main encounter-level fact table (raw load target; cleaned in staging)
CREATE TABLE encounters (
    encounter_id                INTEGER PRIMARY KEY,
    patient_nbr                 INTEGER NOT NULL,
    race                        TEXT,
    gender                      TEXT,
    age                         TEXT,           -- banded, e.g. '[70-80)'
    weight                      TEXT,            -- mostly missing ('?')
    admission_type_id           INTEGER,
    discharge_disposition_id    INTEGER,
    admission_source_id         INTEGER,
    time_in_hospital             INTEGER,        -- length of stay, days
    payer_code                   TEXT,
    medical_specialty            TEXT,
    num_lab_procedures           INTEGER,
    num_procedures                INTEGER,
    num_medications                INTEGER,
    number_outpatient             INTEGER,
    number_emergency               INTEGER,
    number_inpatient                INTEGER,
    diag_1                         TEXT,          -- primary ICD-9 diagnosis
    diag_2                         TEXT,
    diag_3                         TEXT,
    number_diagnoses                INTEGER,
    max_glu_serum                    TEXT,
    a1cresult                        TEXT,
    change_in_meds                    TEXT,       -- 'Ch' / 'No'
    diabetes_med                       TEXT,       -- 'Yes' / 'No'
    readmitted                          TEXT       -- '<30', '>30', 'NO'
);

-- Helpful indexes for the KPI and feature queries
CREATE INDEX idx_encounters_patient ON encounters(patient_nbr);
CREATE INDEX idx_encounters_readmit ON encounters(readmitted);
CREATE INDEX idx_encounters_discharge ON encounters(discharge_disposition_id);
