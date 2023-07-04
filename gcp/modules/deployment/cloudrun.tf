resource "google_cloud_run_v2_service" "service" {
  name     = "${var.academy_prefix}-${var.env}-${var.project_name}-run"
  location = var.target_region
  project = var.project

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      #image = "${var.target_region}-docker.pkg.dev/${var.project}/${var.env}-${var.academy_prefix}-acme-cmdb-registry/acme"
    }
  }
}


data "google_iam_policy" "admin" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "policy" {
  location    = var.target_region
  project     = var.project
  service     = google_cloud_run_v2_service.service.name
  policy_data = data.google_iam_policy.admin.policy_data
}
