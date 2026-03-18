# ── Cloud Run Service ─────────────────────────────────────────
resource "google_cloud_run_v2_service" "employee_api" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  # Allow unauthenticated requests
  # (Our API is publicly accessible)
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    # ── Service Account ──────────────────────────────────
    service_account = var.cloud_run_sa_email

    # ── Scaling Configuration ────────────────────────────
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # ── VPC Access ───────────────────────────────────────
    # Connect Cloud Run to our VPC to reach Cloud SQL
    vpc_access {
      network_interfaces {
        network    = var.vpc_name
        subnetwork = var.subnet_name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    # ── Container Configuration ──────────────────────────
    containers {
      # Docker image from Artifact Registry
      image = var.container_image

      # ── Container Resources ──────────────────────────
      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        cpu_idle          = true
        startup_cpu_boost = true
      }

      # ── Container Port ───────────────────────────────
      ports {
        container_port = 8080
      }

      # ── Environment Variables ────────────────────────
      # Inject DATABASE_URL from Secret Manager
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

      # ── Health Checks ────────────────────────────────
      startup_probe {
        http_get {
          path = "/health"
          port = 8080
        }
        initial_delay_seconds = 10
        timeout_seconds       = 5
        period_seconds        = 10
        failure_threshold     = 3
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

    # ── Labels ──────────────────────────────────────────
    labels = {
      environment = var.environment
      application = "employee-api"
      managed-by  = "terraform"
    }
  }

  # ── Traffic Configuration ────────────────────────────────
  # Send 100% traffic to latest revision
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