resource "google_cloud_run_service" "service" {
  name     = "${var.academy_prefix}-${var.project_name}-run"
  location = var.target_region

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
    vpc_access{
      connector = module.vpc_access.connector.id
      egress = "ALL_TRAFFIC"
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
  service     = google_cloud_run_service.service.name
  policy_data = data.google_iam_policy.admin.policy_data
}

