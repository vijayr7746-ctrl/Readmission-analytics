"""
data_prep.py
Reusable functions for loading and cleaning the diabetes readmissions
dataset. Mirrors the cleaning logic in sql/02_load_and_clean.sql so the
notebook and SQL layer stay in sync; use this module when working purely
in Python (e.g. if you skip the SQL layer and load the raw CSV directly).
"""

import pandas as pd

# Discharge disposition codes representing hospice or death — these
# encounters are excluded because the patient cannot be readmitted.
EXPIRED_HOSPICE_CODES = [11, 13, 14, 19, 20, 21]

MISSING_SENTINEL = "?"


# Raw CSV column names that differ from the schema/feature-engineering
# naming convention used throughout this project.
RAW_COLUMN_RENAMES = {
    "A1Cresult": "a1cresult",
    "change": "change_in_meds",
    "diabetesMed": "diabetes_med",
}


def load_raw(path: str) -> pd.DataFrame:
    """Load the raw diabetic_data.csv file and rename columns to match
    the naming convention used by the SQL schema and features.py."""
    df = pd.read_csv(path)
    return df.rename(columns=RAW_COLUMN_RENAMES)


def clean_missing(df: pd.DataFrame) -> pd.DataFrame:
    """Replace the dataset's '?' sentinel with proper NaN values."""
    return df.replace(MISSING_SENTINEL, pd.NA)


def exclude_terminal_dispositions(df: pd.DataFrame) -> pd.DataFrame:
    """Remove encounters where the patient died or was discharged to
    hospice, since they cannot be readmitted and would bias the model."""
    return df[~df["discharge_disposition_id"].isin(EXPIRED_HOSPICE_CODES)].copy()


def add_target(df: pd.DataFrame) -> pd.DataFrame:
    """Create the binary 30-day readmission target."""
    df = df.copy()
    df["readmitted_30d"] = (df["readmitted"] == "<30").astype(int)
    return df


def basic_clean_pipeline(path: str) -> pd.DataFrame:
    """Convenience wrapper: load, clean missing values, apply exclusions,
    and create the target column in one call."""
    df = load_raw(path)
    df = clean_missing(df)
    df = exclude_terminal_dispositions(df)
    df = add_target(df)
    return df


def patient_level_split_ids(df: pd.DataFrame, test_size: float = 0.2,
                              random_state: int = 42):
    """Return train/test patient_nbr sets so that no patient appears in
    both splits (encounters are not independent — a patient may have
    multiple visits)."""
    from sklearn.model_selection import train_test_split

    patients = df["patient_nbr"].unique()
    train_ids, test_ids = train_test_split(
        patients, test_size=test_size, random_state=random_state
    )
    return set(train_ids), set(test_ids)
