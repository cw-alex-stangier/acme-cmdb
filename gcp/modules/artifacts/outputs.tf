output "urls-reg" {
  value = google_artifact_registry_repository.registry.id
}

output "urls-repo" {
  value = google_sourcerepo_repository.repo.name
}