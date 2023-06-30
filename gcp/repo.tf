resource "google_sourcerepo_repository" "repo" {
  name = var.project_name

  provisioner "local-exec" {
      command = "git remote add acme-repo https://source.developers.google.com/p/${var.project}/r/${var.project_name}"
      interpreter = ["sh"]
  }
}