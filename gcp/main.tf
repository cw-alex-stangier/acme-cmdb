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
    "vpcaccess.googleapis.com"
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
  count = var.runservices ? 1 : 0

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


