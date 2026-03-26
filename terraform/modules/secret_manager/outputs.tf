output "db_password_secret_id" {
  description = "Secret ID for database password"
  value       = google_secret_manager_secret.db_password.secret_id
}

output "db_url_secret_id" {
  description = "Secret ID for database URL"
  value       = google_secret_manager_secret.db_url.secret_id
}

output "db_password_secret_name" {
  description = "Full resource name of db password secret"
  value       = google_secret_manager_secret.db_password.name
}

output "db_url_secret_name" {
  description = "Full resource name of db URL secret"
  value       = google_secret_manager_secret.db_url.name
}