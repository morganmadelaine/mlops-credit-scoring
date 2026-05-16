output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "raw_data_bucket" {
  description = "GCS bucket for raw data"
  value       = google_storage_bucket.raw_data.name
}

output "bigquery_datasets" {
  description = "BigQuery dataset IDs"
  value = {
    raw     = google_bigquery_dataset.raw.dataset_id
    staging = google_bigquery_dataset.staging.dataset_id
    marts   = google_bigquery_dataset.marts.dataset_id
  }
}

output "artifact_registry" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.images.repository_id}"
}
