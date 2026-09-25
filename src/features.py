"""
features.py
Feature engineering for the readmissions model: ICD-9 diagnosis grouping,
utilization history features, and medication-change flags.
"""

import pandas as pd


def icd9_to_category(code) -> str:
    """Map an ICD-9 diagnosis code to a broad clinical category.
    This is a simplified grouping commonly used with this dataset;
    refine ranges as needed for your analysis.
    """
    if pd.isna(code):
        return "Missing"

    code = str(code)
    if code.startswith(("V", "E")):
        return "Other (V/E code)"

    try:
        num = float(code)
    except ValueError:
        return "Other"

    if 390 <= num <= 459 or num == 785:
        return "Circulatory"
    if 460 <= num <= 519 or num == 786:
        return "Respiratory"
    if 520 <= num <= 579 or num == 787:
        return "Digestive"
    if str(code).startswith("250"):
        return "Diabetes"
    if 800 <= num <= 999:
        return "Injury"
    if 710 <= num <= 739:
        return "Musculoskeletal"
    if 580 <= num <= 629 or num == 788:
        return "Genitourinary"
    if 140 <= num <= 239:
        return "Neoplasms"
    return "Other"


def add_diagnosis_categories(df: pd.DataFrame) -> pd.DataFrame:
    """Add category columns for the three diagnosis fields."""
    df = df.copy()
    for col in ["diag_1", "diag_2", "diag_3"]:
        df[f"{col}_category"] = df[col].apply(icd9_to_category)
    return df


def add_utilization_features(df: pd.DataFrame) -> pd.DataFrame:
    """Create a simple 'high utilizer' flag and total prior visits
    feature from the outpatient/emergency/inpatient visit counts."""
    df = df.copy()
    df["total_prior_visits"] = (
        df["number_outpatient"] + df["number_emergency"] + df["number_inpatient"]
    )
    df["high_utilizer_flag"] = (df["number_inpatient"] >= 2).astype(int)
    return df


def add_med_change_flags(df: pd.DataFrame) -> pd.DataFrame:
    """Binary-encode medication change and diabetes medication columns."""
    df = df.copy()
    df["med_changed"] = (df["change_in_meds"] == "Ch").astype(int)
    df["on_diabetes_med"] = (df["diabetes_med"] == "Yes").astype(int)
    return df


def build_feature_set(df: pd.DataFrame) -> pd.DataFrame:
    """Run the full feature engineering pipeline."""
    df = add_diagnosis_categories(df)
    df = add_utilization_features(df)
    df = add_med_change_flags(df)
    return df
