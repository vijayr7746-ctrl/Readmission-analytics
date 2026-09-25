# Predicting 30-Day Hospital Readmissions in Diabetic Patients

A healthcare analytics project that identifies which inpatient diabetes encounters
are likely to result in a 30-day readmission, and translates that into actionable
recommendations for a hospital care-management team.

## Business problem

Under the CMS Hospital Readmissions Reduction Program (HRRP), hospitals are
financially penalized for excess 30-day readmissions. Diabetes is one of the
most common comorbidities driving avoidable readmissions. This project asks:

- What is our 30-day readmission rate, and how does it vary by diagnosis,
  age, length of stay, and discharge disposition?
- Which patients are at highest risk of readmission at the point of discharge?
- Where should a limited care-management team focus follow-up calls or visits
  to get the best reduction in readmissions per dollar spent?

## Data source

**UCI Machine Learning Repository — "Diabetes 130-US Hospitals for Years
1999-2008"**
https://archive.ics.uci.edu/dataset/296/diabetes+130-us+hospitals+for+years+1999-2008

- ~101,766 inpatient encounters across 130 US hospitals
- Demographics, admission/discharge details, diagnoses (ICD-9), lab results,
  medications, and a readmission label (`<30`, `>30`, `NO`)
- Fully de-identified — no PHI/HIPAA concerns, safe for a public portfolio

Download `diabetic_data.csv` and `IDs_mapping.csv` and place them in
`data/raw/`. This project does not redistribute the data.

Optional enrichment: CMS Hospital Readmissions Reduction Program hospital-level
data, for benchmarking against national averages.
https://data.cms.gov/provider-data/dataset/9n3s-kdb3

## Tech stack

| Layer            | Tool                                  |
|-------------------|----------------------------------------|
| Data modeling      | SQL (SQLite/PostgreSQL)               |
| Analysis & ML      | Python (pandas, scikit-learn, xgboost, shap) |
| Dashboard          | Power BI or Tableau Public            |
| Version control    | Git                                    |

## Project structure

```
readmission-analytics/
├── data/
│   ├── raw/              # original CSVs (not committed — see .gitignore)
│   └── processed/        # cleaned tables, model-ready datasets
├── sql/
│   ├── 01_schema.sql            # normalized table definitions
│   ├── 02_load_and_clean.sql    # load raw → clean staging tables
│   ├── 03_kpi_queries.sql       # readmission-rate KPIs by segment
│   └── 04_feature_views.sql     # analytical view consumed by Python
├── notebooks/
│   ├── 01_eda.ipynb             # exploratory data analysis
│   ├── 02_feature_engineering.ipynb
│   ├── 03_modeling.ipynb        # baseline + gradient boosting + SHAP
│   └── 04_fairness_check.ipynb  # subgroup performance audit
├── src/
│   ├── data_prep.py             # reusable cleaning functions
│   ├── features.py              # feature engineering functions
│   └── model.py                 # train/evaluate/export model
├── dashboard/                   # .pbix / .twbx + exported screenshots
├── reports/
│   └── findings_summary.md      # 1-page, non-technical summary
├── requirements.txt
├── .gitignore
└── README.md
```

## Roadmap

- [ ] **Phase 1 — SQL:** load raw data, build normalized schema, write KPI
      queries (readmission rate by age/diagnosis/discharge type/LOS)
- [ ] **Phase 2 — EDA & cleaning:** handle missing values, exclude
      hospice/expired dispositions, group ICD-9 codes into clinical categories
- [ ] **Phase 3 — Modeling:** logistic regression baseline → XGBoost/LightGBM,
      patient-level train/test split, PR-AUC/recall focus (positive class ~11%),
      SHAP explanations
- [ ] **Phase 4 — Fairness check:** compare model performance/error rates
      across race, gender, and age groups
- [ ] **Phase 5 — Dashboard:** executive KPI page, drill-down page, risk
      stratification page with model scores
- [ ] **Phase 6 — Write-up:** README (this file) + one-page findings summary
      for a non-technical hospital administrator

## Key methodological notes (things interviewers ask about)

- **Exclusions:** patients discharged to hospice or who died during the stay
  are excluded from the readmission target, since they cannot be readmitted.
- **Split strategy:** the dataset contains repeat encounters for the same
  patient. Splitting randomly by encounter leaks patient identity across
  train/test. Always split by `patient_nbr`.
- **Class imbalance:** only ~11% of encounters are readmitted within 30 days.
  Accuracy is a misleading metric — use PR-AUC, recall, and a cost-weighted
  threshold instead.
- **Data vintage:** the dataset covers 1999–2008. This is explicitly called
  out as a limitation — clinical practice and coding (ICD-9 vs ICD-10) have
  since changed.

## License

Project code: MIT. Data: subject to the UCI repository's terms — not
redistributed in this repo.
