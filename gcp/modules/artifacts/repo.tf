resource "google_sourcerepo_repository" "repo" {
  name = "${var.academy_prefix}-${var.env}-${var.project_name}-repo"
  project = var.project

  #add current repo
  provisioner "local-exec" {
    command = "git remote add ${google_sourcerepo_repository.repo.name} https://source.developers.google.com/p/${var.project}/r/${google_sourcerepo_repository.repo.name}"
  }

  #push to repo
  provisioner "local-exec" {
    command = "git push ${google_sourcerepo_repository.repo.name} main"
  }

  #remove remote repo
  provisioner "local-exec" {
    when    = destroy
    command = "git remote remove ${self.name}"
  }
}