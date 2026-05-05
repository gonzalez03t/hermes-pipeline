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

# ── Cloud Run (prod-specific) ──────────────────────────────────────────────────

module "cloud_run" {
  source = "../../modules/cloud-run"

  project_id    = var.project_id
  region        = var.region
  service_name  = "hermes-pipeline-${var.environment}"
  image         = var.image
  environment   = var.environment
  database_name = "(default)"
}

# ── Observability — uptime check ───────────────────────────────────────────────

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

# ── Observability — availability SLO (prod only) ───────────────────────────────

resource "google_monitoring_custom_service" "app" {
  project      = var.project_id
  service_id   = "hermes-pipeline-${var.environment}"
  display_name = "Hermes Pipeline ${var.environment}"
}

resource "google_monitoring_slo" "availability" {
  project      = var.project_id
  service      = google_monitoring_custom_service.app.service_id
  slo_id       = "hermes-pipeline-availability"
  display_name = "Hermes Pipeline availability SLO"
  goal         = 0.995

  rolling_period_days = 30

  request_based_sli {
    good_total_ratio {
      good_service_filter = join(" AND ", [
        "metric.type=\"run.googleapis.com/request_count\"",
        "resource.type=\"cloud_run_revision\"",
        "resource.label.\"service_name\"=\"hermes-pipeline-${var.environment}\"",
        "metric.label.\"response_code_class\"=\"2xx\"",
      ])
      total_service_filter = join(" AND ", [
        "metric.type=\"run.googleapis.com/request_count\"",
        "resource.type=\"cloud_run_revision\"",
        "resource.label.\"service_name\"=\"hermes-pipeline-${var.environment}\"",
      ])
    }
  }
}
