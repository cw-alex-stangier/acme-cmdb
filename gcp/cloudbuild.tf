module "cloudbuild_github" {
  source  = "memes/cloudbuild/google//modules/github"
  version = "1.1.0"

  name = "${var.env}-${var.academy_prefix}-${var.project_name}-trigger"
  project_id  = var.project
  source_repo = "cw-alex-stangier/acme-cmdb"

  trigger_config = {
    branch_regex = "main$"
    is_pr_trigger = true
    comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    tag_regex = null
  }

  filename = "../cloudbuild.yml"

}