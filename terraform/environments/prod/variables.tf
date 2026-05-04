variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev or prod)."
  type        = string
}

variable "image" {
  description = "Full container image URL to deploy."
  type        = string
}
