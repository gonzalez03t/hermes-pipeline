terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_firestore_database" "db" {
  project     = var.project_id
  name        = var.database_name
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
}

resource "google_firestore_index" "items_name_created_at" {
  project    = var.project_id
  database   = google_firestore_database.db.name
  collection = "items"

  fields {
    field_path = "name"
    order      = "ASCENDING"
  }

  fields {
    field_path = "createdAt"
    order      = "DESCENDING"
  }
}
