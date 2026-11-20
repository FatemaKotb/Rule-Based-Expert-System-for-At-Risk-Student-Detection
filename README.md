# Rule-Based Expert System for Early Identification of At-Risk Students

A rule-based expert system that flags students at risk of failing or withdrawing from online courses early enough to intervene. Interpretable IF-THEN rules are extracted from a shallow decision tree and run in an [Experta](https://github.com/nilp0inter/experta) inference engine, then benchmarked against logistic regression and SVM baselines. On the Open University Learning Analytics Dataset (OULAD), using only the first 14 weeks of enrolment, the expert system matched the baselines while reaching the highest recall — and, unlike them, kept its full decision logic readable as 14 rules.

Built as the course project for CMP610 Expert Systems (Postgraduate Studies, Cairo University). The write-up is in [`paper/paper.pdf`](paper/paper.pdf), with LaTeX source in [`paper/`](paper/).

## Repository

```
.
├── oulad/                               # primary implementation (used in the paper)
│   ├── preprocess_oulad.R               # preprocessing via the ouladFormat package
│   ├── oulad_eda.ipynb                  # exploratory data analysis
│   ├── oulad_risk_es_vs_ml.ipynb        # rule extraction, Experta ES, LR + SVM, evaluation
│   ├── render_oulad_rules_tree.py       # renders the decision-tree figure
│   ├── oulad_generated_expert_system_rules.csv / .json   # extracted knowledge base
│   ├── oulad_decision_tree_from_rules.png
│   └── data/oulad_processed.csv         # preprocessed, model-ready dataset
├── uci-student-performance/             # earlier exploratory version, kept for reference
└── paper/                               # LaTeX source and compiled PDF
```

## Running it

Install the dependencies — Python for the notebooks and figures, R only for regenerating the OULAD data:

```
pip install pandas matplotlib scikit-learn experta jupyter
```
```r
install.packages("ouladFormat")
```

The pipeline runs in four stages inside `oulad/`. The processed dataset is already committed, so you can skip straight to stage 2:

1. `preprocess_oulad.R` — rebuild `data/oulad_processed.csv` from the raw OULAD data (downloaded by `ouladFormat`).
2. `oulad_eda.ipynb` — explore the data and produce the target-distribution figures.
3. `oulad_risk_es_vs_ml.ipynb` — extract the rule base, run the expert system, and compare it against the LR and SVM baselines.
4. `render_oulad_rules_tree.py` — render the decision-tree figure from the extracted rules.

A fixed random seed (42) is used throughout for reproducibility.

## Results

On the held-out test set (positive class: At Risk):

| System | Accuracy | Precision | Recall | F1 |
|---|---|---|---|---|
| Expert System | 0.832 | 0.740 | **0.778** | 0.759 |
| Logistic Regression | 0.828 | 0.738 | 0.768 | 0.753 |
| SVM | **0.849** | **0.784** | 0.768 | **0.776** |

Average continuous assessment score was the dominant predictor across the 14-rule knowledge base.

---

Fatema Kotb and Noran Hany · Licensed under MIT.
