variable "billing_account_id" {
  description = "GCP billing account ID to associate with the project."
  type        = string
}

variable "project_id" {
  description = "GCP project ID."
  type        = string
  default     = "gonzalez03t-portfolio"
}

variable "region" {
  description = "Default GCP region."
  type        = string
  default     = "us-east1"
}
