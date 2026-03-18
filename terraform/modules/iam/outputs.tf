output "cloud_run_sa_email" {
  description = "Email of the Cloud Run service account"
  value       = google_service_account.cloud_run_sa.email
}

output "github_actions_sa_email" {
  description = "Email of the GitHub Actions service account"
  value       = google_service_account.github_actions_sa.email
}

output "github_actions_sa_name" {
  description = "Full name of the GitHub Actions service account"
  value       = google_service_account.github_actions_sa.name
}