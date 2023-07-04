variable "target_region" {
  type = string
  nullable = false
  description = "The desired region for the deployment."
}

variable "target_zone" {
  type = string
  nullable = false
  description = "The desired zone for the deployment."
}
variable "academy_prefix" {
  type = string
  nullable = false
  description = "Prefix to distinguish between academy members."
}
variable "project_name" {
  type = string
  nullable = false
  description = "Name of the project."
}
variable "project" {
  type = string
  nullable = false
  description = "Project Id."
}

variable "runservices" {
  type = bool
  default = false
}

variable "env" {
  type = string
}

variable "repo_name" {
  type = string
}