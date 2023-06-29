#Create Service Account for CICD Purposes
resource "google_service_account" "service_account_cicd" {
  account_id   = "${var.academy_prefix}-${var.project_name}-1"
  display_name = "${var.academy_prefix}-${var.project_name}-cicd"
  description   = "[AS] ACME CMDB CICD Service Account"
}

#Create Service Account for CMDB Purposes
resource "google_service_account" "service_account_cmdb" {
  account_id   = "${var.academy_prefix}-${var.project_name}-2"
  display_name = "${var.academy_prefix}-${var.project_name}-cmdb"
  description   = "[AS] ACME CMDB Service Account"
}

#Assign basic role
resource "google_service_account_iam_binding" "serviceAccountUserRole" { 
  service_account_id = google_service_account.service_account_cicd.name

  for_each   = toset(["roles/owner"])
  role       = each.key

  members = [
    "serviceAccount:${google_service_account.service_account_cicd.email}",
    "serviceAccount:${google_service_account.service_account_cmdb.email}",
  ]
}

#Assign CICD specific roles
resource "google_service_account_iam_binding" "serviceAccountCICDRole" { 
  service_account_id = google_service_account.service_account_cicd.name

  for_each   = toset(["roles/run.admin", "roles/artifactregistry.admin"])
  role       = each.key

  members = [
    "serviceAccount:${google_service_account.service_account_cicd.email}",
  ]
}

#Assign CMDB specific roles
resource "google_service_account_iam_binding" "serviceAccountCMDBRole" { 
  service_account_id = google_service_account.service_account_cicd.name

  for_each   = toset(["roles/compute.instanceAdmin.v1"])
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