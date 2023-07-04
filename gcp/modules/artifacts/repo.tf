resource "google_sourcerepo_repository" "repo" {
  name = "${var.academy_prefix}-${var.env}-${var.project_name}-repo"
  project = var.project

  #add current repo
#  provisioner "local-exec" {
#   command = "git remote add ${google_sourcerepo_repository.repo.name} https://source.developers.google.com/p/${var.project}/r/${google_sourcerepo_repository.repo.name}"
#  }

  #push to repo
#  provisioner "local-exec" {
#   command = "git push ${google_sourcerepo_repository.repo.name} main"
#  }

  #remove remote repo
#  provisioner "local-exec" {
#    when    = destroy
#   command = "git remote remove ${self.name}"
#  }
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
  secret_data = file("${path.module}/modules/artifacts/github-token.txt")
}

data "google_iam_policy" "p4sa-secretAccessor" {
  provider = google-beta
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-331094424989@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  provider = google-beta
  secret_id = google_secret_manager_secret.github-token-secret.secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "my-connection" {
  provider = google-beta
  location = "europe-west1"
  name = "${var.academy_prefix}-${var.env}-${var.project_name}-GH-connection"

  github_config {
    #app_installation_id = 123123
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "my-repository" {
  provider = google-beta
  location = "europe-west1"
  name = "${var.academy_prefix}-${var.env}-${var.project_name}-build-repo"
  parent_connection = google_cloudbuildv2_connection.my-connection.name
  remote_uri = "https://github.com/cw-alex-stangier/acme-cmdb"
}