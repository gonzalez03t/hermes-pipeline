output "project_id" {
  description = "The GCP project ID."
  value       = google_project.portfolio.project_id
}

output "tfstate_bucket_dev" {
  description = "Name of the GCS bucket used for dev Terraform state."
  value       = google_storage_bucket.tfstate_dev.name
}

output "tfstate_bucket_prod" {
  description = "Name of the GCS bucket used for prod Terraform state."
  value       = google_storage_bucket.tfstate_prod.name
}
