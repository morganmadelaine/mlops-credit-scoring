variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region for resources"
  type        = string
  default     = "europe-west1"
}

variable "bq_location" {
  description = "BigQuery datasets location"
  type        = string
  default     = "EU"
}
