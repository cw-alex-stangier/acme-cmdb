output "bucket" {
  value = aws_instance.server.private_ip
}

output "random" {
  value = random_string.random.result
}

output "repo" {
  value = google_sourcerepo_repository.repo.name
}

output "registry" {
  value = google_artifact_registry_repository.registry.name
}

output "worker-email" {
  value = google_service_account.service_account.email
}