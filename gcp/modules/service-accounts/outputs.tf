output "service-account-cicd" {
  value = google_service_account.service_account_cicd.email
}

output "service-account-cmdb" {
  value = google_service_account.service_account_cmdb.email
}