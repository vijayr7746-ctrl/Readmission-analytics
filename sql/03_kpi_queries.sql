-- ============================================================
-- 03_kpi_queries.sql
-- Business KPIs for the executive dashboard page.
-- All queries run against encounters_clean (see 02_load_and_clean.sql).
-- ============================================================

-- 1. Overall 30-day readmission rate
SELECT
    COUNT(*)                                   AS total_encounters,
    SUM(readmitted_30d)                         AS readmissions_30d,
    ROUND(100.0 * SUM(readmitted_30d) / COUNT(*), 2) AS readmit_rate_pct
FROM encounters_clean;

-- 2. Readmission rate by age band
SELECT
    age,
    COUNT(*)                                   AS encounters,
    SUM(readmitted_30d)                         AS readmissions,
    ROUND(100.0 * SUM(readmitted_30d) / COUNT(*), 2) AS readmit_rate_pct
FROM encounters_clean
GROUP BY age
ORDER BY age;

-- 3. Readmission rate by discharge disposition (top 10 by volume)
SELECT
    d.description                               AS discharge_disposition,
    COUNT(*)                                    AS encounters,
    SUM(e.readmitted_30d)                        AS readmissions,
    ROUND(100.0 * SUM(e.readmitted_30d) / COUNT(*), 2) AS readmit_rate_pct
FROM encounters_clean e
JOIN discharge_disposition_map d
    ON e.discharge_disposition_id = d.discharge_disposition_id
GROUP BY d.description
ORDER BY encounters DESC
LIMIT 10;

-- 4. Readmission rate by length of stay bucket
SELECT
    CASE
        WHEN time_in_hospital <= 2 THEN '1-2 days'
        WHEN time_in_hospital <= 5 THEN '3-5 days'
        WHEN time_in_hospital <= 8 THEN '6-8 days'
        ELSE '9+ days'
    END                                          AS los_bucket,
    COUNT(*)                                     AS encounters,
    SUM(readmitted_30d)                          AS readmissions,
    ROUND(100.0 * SUM(readmitted_30d) / COUNT(*), 2) AS readmit_rate_pct
FROM encounters_clean
GROUP BY los_bucket
ORDER BY los_bucket;

-- 5. Readmission rate by primary diagnosis category (top 15)
--    (diag_1 is raw ICD-9 here; category grouping happens in Python —
--     see src/features.py — this is the pre-grouping raw view)
SELECT
    diag_1,
    COUNT(*)                                     AS encounters,
    SUM(readmitted_30d)                          AS readmissions,
    ROUND(100.0 * SUM(readmitted_30d) / COUNT(*), 2) AS readmit_rate_pct
FROM encounters_clean
WHERE diag_1 IS NOT NULL
GROUP BY diag_1
HAVING COUNT(*) >= 100
ORDER BY encounters DESC
LIMIT 15;

-- 6. Prior utilization vs readmission risk (proxy for "high utilizer" flag)
SELECT
    number_inpatient AS prior_inpatient_visits,
    COUNT(*)                                     AS encounters,
    SUM(readmitted_30d)                          AS readmissions,
    ROUND(100.0 * SUM(readmitted_30d) / COUNT(*), 2) AS readmit_rate_pct
FROM encounters_clean
GROUP BY number_inpatient
ORDER BY prior_inpatient_visits;

-- 7. Repeat-patient identification (window function) —
--    flags each patient's encounter sequence and days since their
--    previous inpatient encounter, for use in feature engineering.
SELECT
    patient_nbr,
    encounter_id,
    ROW_NUMBER() OVER (PARTITION BY patient_nbr ORDER BY encounter_id) AS visit_seq,
    LAG(encounter_id) OVER (PARTITION BY patient_nbr ORDER BY encounter_id) AS prev_encounter_id
FROM encounters_clean
ORDER BY patient_nbr, visit_seq;
