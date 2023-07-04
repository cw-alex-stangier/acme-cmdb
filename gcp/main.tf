terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.70.0"
    }
  }
}

locals {
  project = var.project_name
  services = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "sourcerepo.googleapis.com", 
    "cloudresourcemanager.googleapis.com", 
  ]
}

provider "google" {
  region = var.target_region
  zone = var.target_zone
}

resource "random_string" "random" {
  length = 8
  upper  = false
  special = false
}

#Enable Services
resource "google_project_service" "enabled_service" {
  for_each = toset(local.services)
  project  = var.project
  service  = each.key
  provisioner "local-exec" {
    command = "sleep 60"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "sleep 15"
  }
}


module "artifacts" {
  source = "./modules/artifacts"

  target_region = var.target_region
  target_zone = var.target_zone
  academy_prefix = var.academy_prefix
  project_name = var.project_name
  project = var.project
  env = var.env
  repo_name = var.repo_name
}

module "deployment" {
  source = "./modules/deployment"

  target_region = var.target_region
  target_zone = var.target_zone
  academy_prefix = var.academy_prefix
  project_name = var.project_name
  project = var.project
  env = var.env
  repo_name = var.repo_name
}

module "service-accounts" {
  source = "./modules/service-accounts"

  target_region = var.target_region
  target_zone = var.target_zone
  academy_prefix = var.academy_prefix
  project_name = var.project_name
  project = var.project
  env = var.env
  repo_name = var.repo_name
}

