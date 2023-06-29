output "urls" {
  value = {
    app  = google_cloud_run_service.service.status[0].url
    registry = google_artifact_registry_repository.registry.id
  }
}

output "service-accounts" {
  value = {
    cicd = google_service_account.service_account_cicd.email
#    cicd-pub-key = google_service_account_key.cicd-key.public_key
    cmdb = google_service_account.service_account_cmdb.email
#    cmdb-pub-key = google_service_account_key.cmdb-key.public_key
  }
}