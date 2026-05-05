terraform {
  backend "gcs" {
    bucket = "hermes-pipeline-tfstate-dev"
    prefix = "terraform/state"
  }
}
