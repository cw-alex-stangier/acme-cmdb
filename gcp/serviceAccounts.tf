#Create Service Account for CICD Purposes
resource "google_service_account" "service_account_cicd" {
  account_id   = "${var.env}-${var.academy_prefix}-${var.project_name}-cicd"
  display_name = "${var.env}-${var.academy_prefix}-${var.project_name}-cicd"
  description   = "${var.env} AS ACME CMDB CICD Service Account"
  project = var.project

  #create key
  provisioner "local-exec" {
    command = "gcloud iam service-accounts keys create cicd_key.json --iam-account=${self.email}"
  }

  #delete key on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "rm cicd_key.json"
  }
}

#Create Service Account for CMDB Purposes
resource "google_service_account" "service_account_cmdb" {
  account_id   = "${var.env}-${var.academy_prefix}-${var.project_name}-worker"
  display_name = "${var.env}-${var.academy_prefix}-${var.project_name}-worker"
  description   = "${var.env} AS ACME CMDB Service Account"
  project = var.project

  #create key
  provisioner "local-exec" {
    command = "gcloud iam service-accounts keys create cmdb_key.json --iam-account=${self.email}"
  }

    #delete key on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "rm cmdb_key.json"
  }
}

resource "google_project_iam_binding" "project" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.service_account_cmdb.email}",
    "serviceAccount:${google_service_account.service_account_cicd.email}",
  ]
}



#Assign CICD specific roles
resource "google_project_iam_member" "serviceAccountCICDRole" { 
  project = var.project
  for_each   = toset(["roles/run.admin", "roles/artifactregistry.admin"])
  role       = each.key

  member = "serviceAccount:${google_service_account.service_account_cicd.email}"

  provisioner "local-exec" {
    command = "git push ${google_sourcerepo_repository.repo.name} main"
  }
}

#Assign CMDB specific roles
resource "google_project_iam_member" "serviceAccountCMDBRole" { 
  project = var.project
  for_each   = toset(["roles/compute.admin"])
  role       = each.key

  member = "serviceAccount:${google_service_account.service_account_cmdb.email}"
}


