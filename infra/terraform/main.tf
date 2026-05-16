provider "google" {
  project = var.project_id
  region  = var.region
}

# Bucket pour les données brutes Home Credit
resource "google_storage_bucket" "raw_data" {
  name                        = "${var.project_id}-data"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
}

# Datasets BigQuery selon le pattern medallion (raw / staging / marts)
locals {
  ninety_days_ms = 90 * 24 * 60 * 60 * 1000  # 90 jours × 24h × 3600s × 1000ms = 7 776 000 000 ms
}

resource "google_bigquery_dataset" "raw" {
  dataset_id  = "credit_scoring_raw"
  description = "Raw ingestion of Home Credit Default Risk data"
  location    = var.bq_location
  delete_contents_on_destroy = true
  default_table_expiration_ms = local.ninety_days_ms  # 90 jours
}

resource "google_bigquery_dataset" "staging" {
  dataset_id  = "credit_scoring_staging"
  description = "Cleaned and typed data, dbt staging models"
  location    = var.bq_location
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "marts" {
  dataset_id  = "credit_scoring_marts"
  description = "Business-ready feature store for ML training and serving"
  location    = var.bq_location
  delete_contents_on_destroy = true
}

# Artifact Registry pour stocker les images Docker (API + dashboard)
resource "google_artifact_registry_repository" "images" {
  location      = var.region
  repository_id = "credit-scoring-images"
  description   = "Docker images for credit scoring API and dashboard"
  format        = "DOCKER"
}
