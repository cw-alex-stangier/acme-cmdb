#Create Service Account for CICD Purposes
resource "google_service_account" "service_account_cicd" {
  account_id   = "${var.academy_prefix}-${var.project_name}-1"
  display_name = "${var.academy_prefix}-${var.project_name}-cicd"
  description   = "[AS] ACME CMDB CICD Service Account"
}

#Add Compute Admin Role to service account
resource "google_service_account_iam_binding" "cicd" { 
  service_account_id = google_service_account.service_account_cicd.name

  for_each   = toset(["roles/iam.serviceAccountUser"])
  role       = each.key

  members = [
    "serviceAccount:${google_service_account.service_account_cicd.email}",
  ]
}

#Create Service Account for CMDB Purposes
resource "google_service_account" "service_account_cmdb" {
  account_id   = "${var.academy_prefix}-${var.project_name}-2"
  display_name = "${var.academy_prefix}-${var.project_name}-cmdb"
  description   = "[AS] ACME CMDB Service Account"
}

#Add Compute Admin Role to service account
resource "google_service_account_iam_binding" "compute_admin" { 
  service_account_id = google_service_account.service_account_cmdb.name

  for_each   = toset(["roles/iam.serviceAccountUser"])
  role       = each.key

  members = [
    "serviceAccount:${google_service_account.service_account_cicd.email}",
  ]
}

#Create Keys 
resource "google_service_account_key" "cicd-key" {
  service_account_id = google_service_account.service_account_cicd.name
}

resource "google_service_account_key" "cmdb-key" {
  service_account_id = google_service_account.service_account_cmdb.name
}