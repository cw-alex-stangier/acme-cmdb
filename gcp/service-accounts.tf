#Create Service Account for CICD Purposes
resource "google_service_account" "service_account_cicd" {
  account_id   = "${var.academy_prefix}-${var.env}-${var.project_name}-cicd"
  display_name = "${var.academy_prefix}-${var.env}-${var.project_name}-cicd"
  description   = "${var.env} AS ACME CMDB CICD Service Account"
  project = var.project

  #create key
  provisioner "local-exec" {
    command = "gcloud iam service-accounts keys create cicd_key.json --iam-account=${self.email}"
  }

  #add key to secret manager
  provisioner "local-exec" {
    command = "gcloud secrets create ${self.account_id} --data-file=cicd_key.json"
  }

  #delete key on destroy
  provisioner "local-exec" {
    command = "rm cicd_key.json"
  }

  #delete key on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud secrets delete ${self.account_id} --quiet"
  }
}

#Create Service Account for CMDB Purposes
resource "google_service_account" "service_account_cmdb" {
  account_id   = "${var.academy_prefix}-${var.env}-${var.project_name}-worker"
  display_name = "${var.academy_prefix}-${var.env}-${var.project_name}-worker"
  description   = "${var.env} AS ACME CMDB Service Account"
  project = var.project

  #create key
  provisioner "local-exec" {
    command = "gcloud iam service-accounts keys create cmdb_key.json --iam-account=${self.email}"
  }

  #add key to secret manager
  provisioner "local-exec" {
    command = "gcloud secrets create ${self.account_id} --data-file=cmdb_key.json"
  }

    #delete key on destroy
  provisioner "local-exec" {
    command = "rm cmdb_key.json"
  }

  #delete key on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud secrets delete ${self.account_id} --quiet"
  }
}

#Assign CICD specific roles
resource "google_project_iam_member" "serviceAccountCICDRole" { 
  project = var.project
  for_each   = toset(["roles/run.admin", "roles/artifactregistry.admin", "roles/iam.serviceAccountUser"])
  role       = each.key

  member = "serviceAccount:${google_service_account.service_account_cicd.email}"

  provisioner "local-exec" {
    command = "git push ${google_sourcerepo_repository.repo.name} main"
  }
}

#Assign CMDB specific roles
resource "google_project_iam_member" "serviceAccountCMDBRole" { 
  project = var.project
  for_each   = toset(["roles/compute.admin", "roles/iam.serviceAccountUser"])
  role       = each.key

  member = "serviceAccount:${google_service_account.service_account_cmdb.email}"
}

