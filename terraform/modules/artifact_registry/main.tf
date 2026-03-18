# ── Artifact Registry Repository ──────────────────────────────
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = var.repository_name
  description   = "Docker repository for Employee API images"
  format        = "DOCKER"
  project       = var.project_id

  # Cleanup policy — automatically delete old images
  # Keeps costs low and registry clean 💰
  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 5
    }
  }
}