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

resource "random_string" "random" {
  length = 8
  upper  = false
  special = false
}

#Create Cloud Source Repository
resource "google_sourcerepo_repository" "repo" {
  name = "${var.academy_prefix}-${var.project_name}-repo-${random_string.random.result}"
}

#Add cloud Build trigger
resource "google_cloudbuild_trigger" "trigger" {
  github {
    owner = var.gh_owner
    name  = var.gh_repo
    push {
      branch = "^main$"
    }
  } 

  filename = "../cloudbuild.yaml"
}

#Create Artifact Registry
resource "google_artifact_registry_repository" "registry" {
  location      = var.target_region
  repository_id = "${var.academy_prefix}-${var.project_name}-registry"
  description   = "ACME CMDB Artifact Registry"
  format        = "DOCKER"
}


#Create bucket to store logs
resource "google_storage_bucket" "logs" {
  name          = "${var.academy_prefix}-${var.project_name}-logs"
  location      = "EU"
}
 