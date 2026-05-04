output "database_name" {
  description = "Name of the provisioned Firestore database."
  value       = google_firestore_database.db.name
}
