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
    "sourcerepo.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "iam.googleapis.com",
  ]
  image = "eu.gcr.io/${var.project}/${var.academy_prefix}-${var.project_name}-${random_string.random.result}-img"
}

resource "random_string" "random" {
  length = 8
  upper  = false
  special = false
}

provider "google" {
  region = var.target_region
  zone = var.target_zone
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

resource "google_sourcerepo_repository" "repo" {
  name = "${var.academy_prefix}-${var.project_name}-repo-${random_string.random.result}"
}

resource "google_cloudbuild_trigger" "trigger" {
  trigger_template {
    branch_name = "master"
    repo_name   = google_sourcerepo_repository.repo.name
  }
  build {
    step {
      name = "gcr.io/cloud-builders/go"
      args = ["test"]
      env  = ["PROJECT_ROOT=${var.academy_prefix}-${var.project_name}-${random_string.random.result}"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", local.image, "."]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", local.image]
    }
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = ["run", "deploy", google_cloud_run_service.service.name, "--image", local.image, "--region", var.target_region, "--platform", "managed", "-q"]
    }
  }
}

resource "google_service_account" "service_account" {
  account_id   = "${var.academy_prefix}-${var.project_name}"
  display_name = "${var.academy_prefix}-${var.project_name}-worker"
  description   = "ACME CMDB Service Account"
}

#Add Compute Admin Role to service account
resource "google_service_account_iam_binding" "compute_admin" {
  service_account_id = google_service_account.service_account.name

  for_each   = toset(["roles/run.admin", "roles/iam.serviceAccountUser"])
  role       = each.key

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_cloud_run_service" "service" {
  name     = "${var.academy_prefix}-${var.project_name}-run"
  location = var.target_region
  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "policy" {
  location    = var.target_region
  project     = var.project
  service     = google_cloud_run_service.service.name
  policy_data = data.google_iam_policy.admin.policy_data
}