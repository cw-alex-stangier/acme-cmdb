resource "google_sourcerepo_repository" "repo" {
  name = "${var.academy_prefix}-${var.env}-${var.project_name}-repo"
  project = var.project

  provisioner "local-exec" {
      command = "git remote remove ${google_sourcerepo_repository.repo.name}"
  }

  provisioner "local-exec" {
      command = "git remote add ${google_sourcerepo_repository.repo.name} https://source.developers.google.com/p/${var.project}/r/${google_sourcerepo_repository.repo.name}"
  }

  provisioner "local-exec" {
      command = "git push ${google_sourcerepo_repository.repo.name} main"
  }
}