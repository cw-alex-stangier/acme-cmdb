terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.70.0"
    }
  }
}

provider "google" {
  project = var.project
  region = var.target_region
}


#Create Cloud Source Repository
resource "google_sourcerepo_repository" "repo" {
  name = "${var.academy_prefix}-${var.project_name}-repo"
}

#Create Artifact Registry
resource "google_artifact_registry_repository" "registry" {
  location      = var.target_region
  repository_id = "${var.academy_prefix}-${var.project_name}-registry"
  description   = "ACME CMDB Artifact Registry"
  format        = "DOCKER"
}

#Create Service Acount
resource "google_service_account" "service_account" {
  account_id   = "${var.academy_prefix}-${var.project_name}-worker"
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