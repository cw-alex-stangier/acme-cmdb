#Create Service Account for CICD Purposes
resource "google_service_account" "service_account_cicd" {
  account_id   = "${var.env}-${var.academy_prefix}-${var.project_name}-1"
  display_name = "${var.env}-${var.academy_prefix}-${var.project_name}-cicd"
  description   = "${var.env} [AS] ACME CMDB CICD Service Account"
}

#Create Service Account for CMDB Purposes
resource "google_service_account" "service_account_cmdb" {
  account_id   = "${var.env}-${var.academy_prefix}-${var.project_name}-2"
  display_name = "${var.env}-${var.academy_prefix}-${var.project_name}-cmdb"
  description   = "${var.env} [AS] ACME CMDB Service Account"
}

#Assign CICD specific roles
resource "google_project_iam_member" "serviceAccountCICDRole" { 
  project = var.project
  for_each   = toset(["roles/run.admin", "roles/artifactregistry.admin"])
  role       = each.key

  member = "serviceAccount:${google_service_account.service_account_cicd.email}"
}

#Assign CMDB specific roles
resource "google_project_iam_member" "serviceAccountCMDBRole" { 
  project = var.project
  for_each   = toset(["roles/compute.instanceAdmin.v1"])
  role       = each.key

  member = "serviceAccount:${google_service_account.service_account_cmdb.email}"
}

