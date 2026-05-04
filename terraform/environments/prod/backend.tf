terraform {
  backend "gcs" {
    bucket = "hermes-pipeline-tfstate-prod"
    prefix = "terraform/state"
  }
}
