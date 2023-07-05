resource "google_sourcerepo_repository" "repo" {
  name = "${var.academy_prefix}-${var.env}-${var.project_name}-repo"
  project = var.project
}

#ADD REMOTE GH

resource "google_secret_manager_secret" "github-token-secret" {
  provider = google-beta
  secret_id = "${var.academy_prefix}-github-token-secret"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github-token-secret-version" {
  provider = google-beta
  secret = google_secret_manager_secret.github-token-secret.id
  secret_data = file("${path.module}/github-token.txt")
}

data "google_iam_policy" "p4sa-secretAccessor" {
  provider = google-beta
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-${var.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  provider = google-beta
  secret_id = google_secret_manager_secret.github-token-secret.secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "git-connection" {
  provider = google-beta
  location = "europe-west1"
  name = "${var.academy_prefix}-${var.env}-${var.project_name}-GH-connection"

  github_config {
    app_installation_id = 37356520
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "git-repository" {
  provider = google-beta
  location = "europe-west1"
  name = "${var.academy_prefix}-${var.env}-${var.project_name}-build-repo"
  parent_connection = google_cloudbuildv2_connection.git-connection.name
  remote_uri = "https://github.com/cw-alex-stangier/acme-cmdb.git"
}

# ADD GH TRIGGER
resource "google_cloudbuild_trigger" "push-build-trigger" {
  provider = google-beta

  project     = var.project
  location    = var.target_region
  name = "${var.academy_prefix}-${var.env}-${var.project_name}-trigger"
  description = "Triggers an build if code has been pushed to dev."

  repository_event_config {
    repository = google_cloudbuildv2_repository.git-repository.id
    push {
      branch = ".*"
      #TODO fix trigger branch
    }
  }

  depends_on = [
    google_project_iam_member.act_as,
    google_project_iam_member.logs_writer
  ]

  filename = "cloudbuild-dev.yml"
}

resource "google_service_account" "cloudbuild_service_account" {
  account_id = "cloud-sa"
}

resource "google_project_iam_member" "act_as" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

resource "google_project_iam_member" "run_admin" {
  project = var.project
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}