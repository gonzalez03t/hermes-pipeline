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

# ── Modules ────────────────────────────────────────────────────────────────────

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = "hermes-pipeline"
  environment   = var.environment
}

module "firestore" {
  source = "../../modules/firestore"

  project_id    = var.project_id
  region        = var.region
  database_name = "(default)"
}

module "cloud_run" {
  source = "../../modules/cloud-run"

  project_id    = var.project_id
  region        = var.region
  service_name  = "hermes-pipeline-${var.environment}"
  image         = var.image
  environment   = var.environment
  database_name = module.firestore.database_name
}

# ── GitHub Actions CI service account ─────────────────────────────────────────

resource "google_service_account" "ci" {
  project      = var.project_id
  account_id   = "hermes-pipeline-ci"
  display_name = "Hermes Pipeline GitHub Actions CI"
}

resource "google_project_iam_member" "ci_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.ci.email}"
}

# ── GitHub Actions CD service account ─────────────────────────────────────────

resource "google_service_account" "cd" {
  project      = var.project_id
  account_id   = "hermes-pipeline-cd"
  display_name = "Hermes Pipeline GitHub Actions CD"
}

resource "google_project_iam_member" "cd_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.cd.email}"
}

resource "google_project_iam_member" "cd_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cd.email}"
}

resource "google_project_iam_member" "cd_ar_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.cd.email}"
}

# ── Workload Identity Federation ───────────────────────────────────────────────

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions pool"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.workflow"   = "assertion.workflow"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = "attribute.repository == \"gonzalez03t/hermes-pipeline\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "wif_ci" {
  service_account_id = google_service_account.ci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/gonzalez03t/hermes-pipeline"
}

resource "google_service_account_iam_member" "wif_cd" {
  service_account_id = google_service_account.cd.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/gonzalez03t/hermes-pipeline"
}

# ── Observability — uptime check (dev has uptime check but no SLO) ─────────────

resource "google_monitoring_uptime_check_config" "health" {
  project      = var.project_id
  display_name = "hermes-pipeline-${var.environment}-health"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/api/health"
    port         = 443
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = trimprefix(module.cloud_run.service_url, "https://")
    }
  }
}
