#Create Service Acount
resource "google_service_account" "service_account" {
  account_id   = "${var.academy_prefix}-${var.project_name}"
  display_name = "${var.academy_prefix}-${var.project_name}-worker"
  description   = "ACME CMDB Service Account"
}

#Add Compute Admin Role to service account
resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.service_account.name
  role               = "roles/iam.computeAdmin"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

#Add Storage Admin Role to service account
resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.service_account.name
  role               = "roles/iam.storageAdmin"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

#Add CloudBuild Editor Role to service account
resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.service_account.name
  role               = "roles/iam.cloudbuild.builds.editor"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}
