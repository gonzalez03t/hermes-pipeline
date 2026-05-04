terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project" "portfolio" {
  name            = var.project_id
  project_id      = var.project_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "cloudrun" {
  project            = google_project.portfolio.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "firestore" {
  project            = google_project.portfolio.project_id
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifactregistry" {
  project            = google_project.portfolio.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager" {
  project            = google_project.portfolio.project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  project            = google_project.portfolio.project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iamcredentials" {
  project            = google_project.portfolio.project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "monitoring" {
  project            = google_project.portfolio.project_id
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "tfstate_dev" {
  name                        = "hermes-pipeline-tfstate-dev"
  location                    = "US"
  project                     = google_project.portfolio.project_id
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "tfstate_prod" {
  name                        = "hermes-pipeline-tfstate-prod"
  location                    = "US"
  project                     = google_project.portfolio.project_id
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
