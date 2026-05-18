terraform {
  required_version = ">= 1.14, < 2.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "credit-scoring-mlops-mm-001-tfstate"
    prefix = "terraform/state/main"
  }
}
