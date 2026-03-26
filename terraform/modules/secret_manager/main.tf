# ── Database Password Secret ───────────────────────────────────
resource "google_secret_manager_secret" "db_password" {
  secret_id = "employee-api-db-password"

  replication {
    auto {}
  }

  labels = {
    application = "employee-api"
    managed-by  = "terraform"
  }
}

# Store the actual password value
resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

# ── Database URL Secret ────────────────────────────────────────
resource "google_secret_manager_secret" "db_url" {
  secret_id = "employee-api-db-url"

  replication {
    auto {}
  }

  labels = {
    application = "employee-api"
    managed-by  = "terraform"
  }
}

# Store the full database connection URL
resource "google_secret_manager_secret_version" "db_url" {
  secret      = google_secret_manager_secret.db_url.id
  secret_data = var.db_url
}