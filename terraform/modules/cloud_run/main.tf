# ── Cloud Run Service ─────────────────────────────────────────
resource "google_cloud_run_v2_service" "employee_api" {
  name     = var.service_name
  location = var.region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.cloud_run_sa_email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # ── Cloud SQL Connection ──────────────────────────────
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.cloud_sql_connection]
      }
    }

    containers {
      image = var.container_image

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        cpu_idle          = true
        startup_cpu_boost = true
      }

      ports {
        container_port = 8080
      }

      # ── Mount Cloud SQL socket ────────────────────────
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      # ── Environment Variables ─────────────────────────
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = var.db_url_secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }

      # ── Health Checks ─────────────────────────────────
      startup_probe {
        http_get {
          path = "/health"
          port = 8080
        }
        initial_delay_seconds = 30
        timeout_seconds       = 10
        period_seconds        = 15
        failure_threshold     = 5
      }

      liveness_probe {
        http_get {
          path = "/health"
          port = 8080
        }
        initial_delay_seconds = 15
        timeout_seconds       = 5
        period_seconds        = 30
        failure_threshold     = 3
      }
    }

    labels = {
      environment = var.environment
      application = "employee-api"
      managed-by  = "terraform"
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

# ── Allow Public Access ───────────────────────────────────────
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.employee_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}