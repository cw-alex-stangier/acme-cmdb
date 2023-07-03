output "urls-reg" {
  value = google_artifact_registry_repository.registry.id
}

output "urls-app" {
  value = google_cloud_run_v2_service.service.uri
}

output "service-account-cicd" {
  value = google_service_account.service_account_cicd.email
}

output "service-account-cmdb" {
  value = google_service_account.service_account_cmdb.email
}

output "urls-repo" {
  value = google_sourcerepo_repository.repo.name
}

output "project" {
  value = var.project
}