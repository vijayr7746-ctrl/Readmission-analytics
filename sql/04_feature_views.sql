-- ============================================================
-- 04_feature_views.sql
-- Analytical view exported to Python for feature engineering
-- and modeling (see notebooks/02_feature_engineering.ipynb).
-- ============================================================

DROP VIEW IF EXISTS model_input;

CREATE VIEW model_input AS
SELECT
    e.encounter_id,
    e.patient_nbr,
    e.race,
    e.gender,
    e.age,
    e.admission_type_id,
    at.description        AS admission_type,
    e.discharge_disposition_id,
    dd.description         AS discharge_disposition,
    e.admission_source_id,
    ads.description          AS admission_source,
    e.time_in_hospital,
    e.medical_specialty,
    e.num_lab_procedures,
    e.num_procedures,
    e.num_medications,
    e.number_outpatient,
    e.number_emergency,
    e.number_inpatient,
    e.diag_1,
    e.diag_2,
    e.diag_3,
    e.number_diagnoses,
    e.max_glu_serum,
    e.a1cresult,
    e.change_in_meds,
    e.diabetes_med,
    e.readmitted_30d
FROM encounters_clean e
LEFT JOIN admission_type_map at
    ON e.admission_type_id = at.admission_type_id
LEFT JOIN discharge_disposition_map dd
    ON e.discharge_disposition_id = dd.discharge_disposition_id
LEFT JOIN admission_source_map ads
    ON e.admission_source_id = ads.admission_source_id;

-- Export for Python, e.g. from the sqlite3 CLI:
-- .headers on
-- .mode csv
-- .output data/processed/model_input.csv
-- SELECT * FROM model_input;
-- .output stdout
