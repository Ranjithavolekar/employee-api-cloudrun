# ── Cloud SQL PostgreSQL Instance ─────────────────────────────
resource "google_sql_database_instance" "postgres" {
  name             = var.instance_name
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id

  # Prevent accidental deletion of database! 🔐
  deletion_protection = var.deletion_protection

  settings {
    # db-f1-micro = smallest instance (free tier eligible) 💰
    tier = var.instance_tier

    # ── Availability ────────────────────────────────────────
    availability_type = var.availability_type
    # ZONAL    = single zone (dev/test — cheaper)
    # REGIONAL = multi-zone (production — high availability)

    # ── Disk Settings ───────────────────────────────────────
    disk_size         = var.disk_size
    disk_type         = "PD_SSD"
    disk_autoresize   = true
    disk_autoresize_limit = 100

    # ── Backup Configuration ────────────────────────────────
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

    # ── Maintenance Window ──────────────────────────────────
    maintenance_window {
      day          = 7  # Sunday
      hour         = 3  # 3 AM
      update_track = "stable"
    }

    # ── Network/IP Configuration ────────────────────────────
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.vpc_id
      enable_private_path_for_google_cloud_services = true
    }

    # ── Database Flags ──────────────────────────────────────
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

    # ── Labels ──────────────────────────────────────────────
    user_labels = {
      environment = var.environment
      application = "employee-api"
      managed-by  = "terraform"
    }
  }

  depends_on = [var.private_vpc_connection]
}

# ── Database ───────────────────────────────────────────────────
resource "google_sql_database" "employee_db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

# ── Database User ──────────────────────────────────────────────
resource "google_sql_user" "employee_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
  project  = var.project_id
}