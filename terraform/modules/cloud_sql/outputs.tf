output "instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.postgres.name
}

output "instance_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.postgres.connection_name
}

output "db_name" {
  description = "Database name"
  value       = google_sql_database.employee_db.name
}

output "db_user" {
  description = "Database username"
  value       = google_sql_user.employee_user.name
}

output "public_ip_address" {
  description = "Public IP address of Cloud SQL instance"
  value       = google_sql_database_instance.postgres.public_ip_address
}