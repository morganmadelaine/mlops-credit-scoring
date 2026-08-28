# MLOps Credit Scoring

Production-grade credit scoring pipeline on GCP — portfolio project demonstrating
MLOps and Data Engineering practices.

## Stack

- **Infrastructure**: Terraform (GCS remote backend), GCP (BigQuery, Cloud Storage, Artifact Registry, Cloud Run)
- **Data**: Home Credit Default Risk (Kaggle), medallion architecture (raw / staging / marts)
- **Transformation**: dbt
- **ML**: LightGBM, MLflow tracking, FastAPI serving
- **CI/CD**: GitHub Actions, pre-commit hooks (detect-secrets, branch protection)

## Status

🚧 Work in progress — Phase 0: data ingestion & transformation layer

## Definition of Done (v1)

- [ ] Trained model with experiments tracked in MLflow
- [ ] FastAPI scoring API, containerized (Docker)
- [ ] CI pipeline: lint, tests, image build
- [ ] Architecture diagram, model metrics, 3-command run instructions

## Out of scope v1

Kubernetes, drift monitoring, advanced hyperparameter tuning, feature store,
automated retraining. These belong to the next project (data platform flagship).

## Target project completion date
September 20, 2026
