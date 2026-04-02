# 🛡️ Sentinel-X: Fraud Detection System

A fraud detection pipeline built entirely in **BigQuery ML**, designed to identify suspicious financial transactions across gaming and fintech payment categories.

> **Key highlight:** This project includes a documented data leakage fix — the original model trained on the same rules used to generate the fraud label, inflating AUC to 0.89. Version 2 corrects this with behavior-derived features and achieves a legitimate AUC of **0.79**.

---

## 📐 Architecture
```
transactions (10M rows)
        ↓
transactions_features   ← behavior features engineered here
        ↓
sentinel_model          ← BigQuery ML logistic regression
```

---

## 🗂️ Dataset

Synthetic transaction data simulating a gaming/fintech platform — 10,000,000 rows, 887MB.

| Column | Type | Description |
|---|---|---|
| `tx_id` | STRING | Unique transaction ID |
| `user_id` | INT64 | User identifier |
| `amount` | FLOAT64 | Transaction amount (USD) |
| `tx_timestamp` | TIMESTAMP | Transaction time |
| `tx_category` | STRING | In-Game Purchase, P2P Transfer, Crypto Top-up, Retail, Subscription |
| `device_risk_level` | INT64 | Device risk score (1–5) |
| `is_fraud` | INT64 | Binary label (1 = fraud) |

---

## ⚠️ Data Leakage — Problem & Fix

### The problem (v1)
The original model trained directly on `amount`, `tx_category`, and `device_risk_level` — the exact same fields used to define `is_fraud`:
```sql
-- Label generation rule (source of leakage)
WHEN (tx_category IN ('Crypto Top-up', 'In-Game Purchase') 
      AND amount > 6000 
      AND device_risk_level > 3) THEN 1
```

Training on these features meant the model was memorizing the labeling rules, not learning fraud patterns. AUC of 0.89 was fictitious.

### The fix (v2)
Replaced leaked features with **behavior-derived features** calculated using temporal window functions — always looking backward, never including the current row:

| Feature | Description | Window |
|---|---|---|
| `tx_velocity_24h` | Transaction count in prior 24h | `RANGE 86400 PRECEDING AND 1 PRECEDING` |
| `amount_z_score` | Z-score vs. user's historical average | `ROWS UNBOUNDED PRECEDING AND 1 PRECEDING` |
| `hour_of_day` | Hour extracted from timestamp | N/A — purely temporal |

---

## 📊 Model Results

| Metric | v1 (leaked) | v2 (clean) |
|---|---|---|
| AUC-ROC | 0.89 ❌ | **0.79** ✅ |
| Recall | — | 0.88 |
| Precision | — | 0.076 |
| F1 Score | — | 0.14 |

**Note on precision:** The low precision is expected — fraud is ~1% of transactions (severe class imbalance). The model prioritizes recall to minimize missed fraud cases, which is standard in production fraud detection.

### Confusion Matrix
![Confusion Matrix](matriz%20de%20confusion.png)

### ROC Curve
![ROC Curve](area%20bajo%20la%20curva.png)

### Metrics
![Metrics](metricas%20agregadas.png)

---

## 🔧 How to Run

Execute the SQL files in order:
```bash
1. sql/1_create_transactions.sql    # Generate synthetic data (10M rows)
2. sql/2_create_features.sql        # Engineer behavior features
3. sql/3_train_model.sql            # Train logistic regression model
```

**Requirements:** Google Cloud project with BigQuery and BigQuery ML enabled.

---

## 🧰 Stack

- **Google BigQuery** — data warehouse & SQL engine
- **BigQuery ML** — in-database model training
- **Standard SQL** — window functions for feature engineering

---

*Built by [@axldylxn](https://github.com/axldylxn)*
