resource "google_artifact_registry_repository" "registry" {
  location      = var.target_region
  repository_id = "${var.academy_prefix}-${var.project_name}-registry"
  description   = "Docker container Repository for ${var.academy_prefix}-${var.project_name}"
  format        = "DOCKER"
}