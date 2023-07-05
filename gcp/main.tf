terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.70.0"
    }
  }
}

data "google_project" "project" {}

provider "google" {
  region = var.target_region
  zone = var.target_zone
}

variable "gcp_service_list" {
  description ="The list of apis necessary for the project"
  type = list(string)
  default = [
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "sourcerepo.googleapis.com"
  ]
}

#Activate APIs
resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project = var.project
  service = each.key

  provisioner "local-exec" {
    command = "sleep 60"
  }

  #Remove Apis from state so they wont be disabled on destroy
  provisioner "local-exec" {
    command = "terraform state rm google_project_service.cp_services"
  }
}

resource "random_string" "random" {
  length = 8
  upper  = false
  special = false
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
  project_number = data.google_project.project.number
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
  service_account_email = module.service-accounts.service-account-cicd
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
  project_number = data.google_project.project.number

}

