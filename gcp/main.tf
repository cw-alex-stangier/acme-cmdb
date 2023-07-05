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

