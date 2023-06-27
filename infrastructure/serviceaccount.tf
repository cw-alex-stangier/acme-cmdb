#Create Service Acount
resource "google_service_account" "service_account" {
  account_id   = "${var.academy_prefix}-${var.project_name}"
  display_name = "${var.academy_prefix}-${var.project_name}-worker"
  description   = "ACME CMDB Service Account"
}

#Add Compute Admin Role to service account
resource "google_service_account_iam_binding" "compute_admin" {
  service_account_id = google_service_account.service_account.name
  role               = google_project_iam_custom_role.custom-role.role_id

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_project_iam_custom_role" "custom-role" {
  role_id     = "acmecmdbRole"
  title       = "${var.academy_prefix}-${var.project_name}-sa-role"
  description = "ACME CMDB Custom Role"
  permissions = ["roles/compute.instanceAdmin", "roles/storage.objectAdmin", "roles/cloudbuild.builds.editor"]
}