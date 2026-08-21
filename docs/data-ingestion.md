# Data Ingestion

## Source

[Home Credit Default Risk](https://www.kaggle.com/competitions/home-credit-default-risk) —
Kaggle competition dataset, 8 relational tables, ~2.5 GB raw CSV.

## Flow

Kaggle API → local disk → GCS (`raw/` prefix) → BigQuery (`credit_scoring_raw`)

This is an ELT pattern: data lands untransformed in the warehouse,
transformation happens downstream in dbt.

All 10 CSV files are uploaded to GCS, including `HomeCredit_columns_description.csv`
(data dictionary) and `sample_submission.csv` (Kaggle artefact). Only the 8 relational
tables are loaded into BigQuery.

## Tables

| Table | Rows | BQ size | Grain |
|---|---|---|---|
| `application_train` | 307,511 | 0.24 GB | one row per loan application (labelled) |
| `application_test` | 48,744 | 0.04 GB | one row per loan application (unlabelled) |
| `bureau` | 1,716,428 | 0.22 GB | one row per credit reported to the credit bureau |
| `bureau_balance` | 27,299,925 | 0.52 GB | monthly balance per bureau credit |
| `previous_application` | 1,670,214 | 0.46 GB | one row per previous Home Credit application |
| `pos_cash_balance` | 10,001,358 | 0.64 GB | monthly balance per POS/cash loan |
| `installments_payments` | 13,605,401 | 0.87 GB | one row per installment payment |
| `credit_card_balance` | 3,840,312 | 0.66 GB | monthly balance per credit card |

Total: 58.5M rows, 3.65 GB — within the BigQuery free tier (10 GB storage).

## Prerequisites

- Kaggle API token at `~/.kaggle/kaggle.json` (legacy credentials, not the managed API token)
- Competition rules accepted on the Kaggle website
- `gcloud` authenticated (`gcloud auth login`, `gcloud auth application-default login`)
- Terraform infrastructure applied (bucket and datasets must exist)

## Run

```powershell
.\scripts\ingest_data.ps1                # full run, downloads from Kaggle
.\scripts\ingest_data.ps1 -SkipDownload  # reuse local CSVs
```

The script aborts if the active `gcloud` project does not match the expected one.
Re-running is safe: `bq load --replace` overwrites tables rather than appending.

## Known limitations

- **Schema inference** — tables are loaded with `--autodetect`. BigQuery infers types
  from a sample, which produces inconsistencies: `FLAG_OWN_CAR` becomes `BOOLEAN`
  (from Y/N values) while `FLAG_MOBIL` becomes `INTEGER` (from 0/1). Semantically
  identical columns end up with different types. Typing is normalised in the dbt
  staging layer.
- **Table expiration** — raw tables expire after 90 days by Terraform policy
  (cost control). Re-run this script to reload.
- **Bootstrap script, not a pipeline** — this PowerShell script exists for
  reproducibility on the development machine. It does not run on Linux, in Docker,
  or in CI. A Python ingestion module with explicit schemas replaces it in the next
  iteration. Production orchestration is out of scope for v1.
