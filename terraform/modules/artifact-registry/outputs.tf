output "repository_url" {
  description = "Full URL of the Artifact Registry Docker repository."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}
