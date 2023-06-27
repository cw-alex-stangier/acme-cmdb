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
  
  mirrorConfig  {
    url = "https://github.com/cw-alex-stangier/acme-cmdb/",

  }
}

#Add cloud Build trigger
resource "google_cloudbuild_trigger" "trigger" {
  location = "EU"

  github {
    owner = var.gh_owner
    name  = var.gh_repo
    push {
      branch = "^main$"
    }
}


#Add cloud Build


#Create Artifact Registry
resource "google_artifact_registry_repository" "registry" {
  location      = var.target_region
  repository_id = "${var.academy_prefix}-${var.project_name}-registry"
  description   = "ACME CMDB Artifact Registry"
  format        = "DOCKER"
}


