# Dashboard

Build this in Power BI Desktop or Tableau Public, using
`data/processed/model_input.csv` (from the SQL layer) or
`data/processed/model_ready.csv` (from the Python feature engineering
notebook) plus `readmission_model.pkl` scores exported to CSV.

## Page 1 — Executive Overview
- KPI cards: total encounters, overall 30-day readmission rate, trend
  over time (if using multi-year data)
- Readmission rate by age band (bar)
- Readmission rate by length-of-stay bucket (line)

## Page 2 — Drill-Down
- Filters: age, gender, race, diagnosis category, discharge disposition
- Readmission rate by diagnosis category (bar, sorted)
- Readmission rate by discharge disposition (bar, sorted)
- Table: encounter-level detail for the current filter selection

## Page 3 — Risk Stratification
- Table of patients/encounters sorted by model risk score (from
  `readmission_model.pkl` predictions, exported as CSV)
- Risk tier buckets (Low / Medium / High) as a slicer
- Recommended action column (e.g. "7-day follow-up call") mapped from
  risk tier
- SHAP top-driver summary per high-risk patient, if exported

## Export checklist
- [ ] Export model predictions: `patient_nbr`, `encounter_id`,
      `pred_proba`, `risk_tier` → `data/processed/risk_scores.csv`
- [ ] Save the finished dashboard file here (`.pbix` or `.twbx`)
- [ ] Export 2-3 PNG screenshots for the README / portfolio site
