# Rule-Based Expert System for Early Identification of At-Risk Students

A rule-based expert system that flags students at risk of failing or withdrawing from online courses early enough to intervene. Interpretable IF-THEN rules are extracted from a shallow decision tree and run in an Experta inference engine, then benchmarked against logistic regression and SVM baselines on the OULAD dataset using only the first 14 weeks of enrolment. The expert system matches the baselines while reaching the highest recall, and keeps its full decision logic readable as 14 rules.

Course project for CMP610 Expert Systems, Cairo University. The paper (PDF and LaTeX source) is in `paper/`.

## Structure

```
oulad/                         primary implementation (used in the paper)
  preprocess_oulad.R           build the cleaned dataset from raw OULAD
  oulad_eda.ipynb              exploratory analysis and figures
  oulad_risk_es_vs_ml.ipynb    rule extraction, expert system, LR + SVM
  render_oulad_rules_tree.py   decision-tree figure
  data/oulad_processed.csv     preprocessed, model-ready dataset
uci-student-performance/       earlier exploratory version, kept for reference
paper/                         LaTeX source + PDF
```

## Running it

Python dependencies:

```bash
pip install pandas matplotlib scikit-learn experta jupyter
```

R, for preprocessing only:

```r
install.packages("ouladFormat")
```

The processed dataset is committed, so you can skip step 1.

1. `oulad/preprocess_oulad.R` — rebuild the cleaned dataset from raw OULAD.
2. `oulad/oulad_eda.ipynb` — exploratory analysis and figures.
3. `oulad/oulad_risk_es_vs_ml.ipynb` — extract the rule base and run the expert system against the LR and SVM baselines.
4. `oulad/render_oulad_rules_tree.py` — render the decision-tree figure.

Seed 42 throughout.

## Results

Test-set performance (positive class: At Risk):

| System | Accuracy | Precision | Recall | F1 |
|---|---|---|---|---|
| Expert System | 0.832 | 0.740 | **0.778** | 0.759 |
| Logistic Regression | 0.828 | 0.738 | 0.768 | 0.753 |
| SVM | **0.849** | **0.784** | 0.768 | **0.776** |

Average continuous assessment score was the dominant predictor across the 14-rule knowledge base.

Licensed under MIT.

## Contributors

| [<img src="https://github.com/FatemaKotb.png" width="80" alt="Fatema Kotb"/><br/>Fatema Kotb](https://github.com/FatemaKotb) | [<img src="https://github.com/NouranHany.png" width="80" alt="Noran Hany"/><br/>Noran Hany](https://github.com/NouranHany) |
|:-:|:-:|