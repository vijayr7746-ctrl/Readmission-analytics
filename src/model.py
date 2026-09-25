"""
model.py
Train and evaluate the readmission risk model. Two models are provided:
a logistic regression baseline and a gradient-boosted tree model, both
evaluated primarily on PR-AUC and recall given the ~11% positive class rate.
"""

import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    average_precision_score,
    classification_report,
    roc_auc_score,
)
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer


def build_preprocessor(numeric_cols, categorical_cols) -> ColumnTransformer:
    return ColumnTransformer(
        transformers=[
            ("num", StandardScaler(), numeric_cols),
            ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_cols),
        ]
    )


def train_logistic_baseline(X_train, y_train, numeric_cols, categorical_cols):
    preprocessor = build_preprocessor(numeric_cols, categorical_cols)
    pipe = Pipeline(
        steps=[
            ("preprocess", preprocessor),
            ("clf", LogisticRegression(max_iter=1000, class_weight="balanced")),
        ]
    )
    pipe.fit(X_train, y_train)
    return pipe


def train_xgboost(X_train, y_train, numeric_cols, categorical_cols):
    from xgboost import XGBClassifier

    preprocessor = build_preprocessor(numeric_cols, categorical_cols)
    scale_pos_weight = (y_train == 0).sum() / max((y_train == 1).sum(), 1)

    pipe = Pipeline(
        steps=[
            ("preprocess", preprocessor),
            (
                "clf",
                XGBClassifier(
                    n_estimators=300,
                    max_depth=4,
                    learning_rate=0.05,
                    subsample=0.8,
                    colsample_bytree=0.8,
                    scale_pos_weight=scale_pos_weight,
                    eval_metric="aucpr",
                    random_state=42,
                ),
            ),
        ]
    )
    pipe.fit(X_train, y_train)
    return pipe


def evaluate(model, X_test, y_test) -> dict:
    """Return PR-AUC, ROC-AUC, and a full classification report.
    PR-AUC is the primary metric given the class imbalance (~11% positive)."""
    proba = model.predict_proba(X_test)[:, 1]
    preds = model.predict(X_test)

    return {
        "pr_auc": average_precision_score(y_test, proba),
        "roc_auc": roc_auc_score(y_test, proba),
        "classification_report": classification_report(y_test, preds),
    }
