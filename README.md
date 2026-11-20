# Rule-Based Expert System for Early Identification of At-Risk Students

A rule-based expert system that flags students at risk of failing or withdrawing from online courses early enough to intervene, benchmarked against logistic regression and SVM baselines. Interpretable IF-THEN rules are extracted from a shallow decision tree and deployed in an [Experta](https://github.com/nilp0inter/experta) inference engine, achieving the highest recall of the three systems while keeping the full decision logic inspectable.

Built on the Open University Learning Analytics Dataset (OULAD), using only the first 14 weeks of enrolment so that predictions can be acted on while there is still time to help.

## Paper

**Rule-Based Expert System for Early Identification of At-Risk Students in Online Learning** — Fatema Kotb and Noran Hany, Computer Engineering Department, Faculty of Engineering, Cairo University.

Read it: [`paper/paper.pdf`](paper/paper.pdf). LaTeX source in [`paper/`](paper/).

## Course Context

Course project for CMP610 Expert Systems (Postgraduate Studies, Cairo University), combining expert systems with machine learning.

## Repository Structure

```
.
├── oulad/                               # primary implementation (used in the paper)
│   ├── preprocess_oulad.R               # preprocessing via the ouladFormat package
│   ├── oulad_eda.ipynb                  # exploratory data analysis
│   ├── oulad_risk_es_vs_ml.ipynb        # rule extraction, Experta ES, LR + SVM, evaluation
│   ├── render_oulad_rules_tree.py       # renders the decision-tree figure
│   ├── oulad_generated_expert_system_rules.csv
│   ├── oulad_generated_expert_system_knowledge_base.json
│   ├── oulad_decision_tree_from_rules.png
│   └── data/oulad_processed.csv         # preprocessed, model-ready dataset
├── uci-student-performance/             # earlier exploratory version, kept for reference
├── paper/                               # LaTeX source and compiled PDF
└── README.md
```

## Setup

Python (notebooks and figure rendering):

```
pip install pandas matplotlib scikit-learn experta jupyter
```

R (OULAD preprocessing only):

```r
install.packages("ouladFormat")
```

A fixed random seed (42) is used throughout for reproducibility.

## Reproducing the Results

1. *(Optional)* Run `oulad/preprocess_oulad.R` to regenerate `data/oulad_processed.csv`; skip to use the committed file.
2. Run `oulad/oulad_eda.ipynb` for the exploratory analysis and figures.
3. Run `oulad/oulad_risk_es_vs_ml.ipynb` to extract the rule base and run the expert system alongside the LR and SVM baselines.
4. *(Optional)* Run `oulad/render_oulad_rules_tree.py` to regenerate the decision-tree figure.

The raw OULAD data is downloaded by `ouladFormat`; the processed CSV is committed, so the notebooks run without regenerating it.

## Results (test set, positive class: At Risk)

| System | Accuracy | Precision | Recall | F1 |
|---|---|---|---|---|
| Expert System | 0.832 | 0.740 | **0.778** | 0.759 |
| Logistic Regression | 0.828 | 0.738 | 0.768 | 0.753 |
| SVM | **0.849** | **0.784** | 0.768 | **0.776** |

Average continuous assessment score was the dominant predictor in the 14-rule knowledge base.

## Authors

Fatema Kotb and Noran Hany.

## License

MIT — see [`LICENSE`](LICENSE).
