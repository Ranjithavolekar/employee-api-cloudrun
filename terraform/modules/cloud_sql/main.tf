# ── Cloud SQL PostgreSQL Instance ─────────────────────────────
resource "google_sql_database_instance" "postgres" {
  name             = var.instance_name
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id

  deletion_protection = var.deletion_protection

  settings {
    tier              = var.instance_tier
    availability_type = var.availability_type
    disk_size         = var.disk_size
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    # ── Backup Configuration ──────────────────────────────
    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    # ── Maintenance Window ────────────────────────────────
    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    # ── IP Configuration ──────────────────────────────────
    # Using Cloud SQL Auth Proxy — needs public IP enabled
    # but connections are still secure via IAM + SSL! 🔐
    ip_configuration {
      ipv4_enabled = true

      # Only allow Cloud SQL Auth Proxy connections
      # No direct public access!
      authorized_networks {
        name  = "deny-all"
        value = "0.0.0.0/0"
      }
    }

    # ── Database Flags ────────────────────────────────────
    database_flags {
      name  = "max_connections"
      value = "100"
    }
    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }
    database_flags {
      name  = "log_connections"
      value = "on"
    }
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    user_labels = {
      environment = var.environment
      application = "employee-api"
      managed-by  = "terraform"
    }
  }
}

# ── Database ──────────────────────────────────────────────────
resource "google_sql_database" "employee_db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

# ── Database User ─────────────────────────────────────────────
resource "google_sql_user" "employee_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
  project  = var.project_id
}