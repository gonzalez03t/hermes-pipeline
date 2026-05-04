output "service_url" {
  description = "URL of the deployed Cloud Run service."
  value       = module.cloud_run.service_url
}
