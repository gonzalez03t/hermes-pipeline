variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region for the Firestore database."
  type        = string
}

variable "database_name" {
  description = "Name of the Firestore database."
  type        = string
  default     = "(default)"
}
