variable "role_name" {
  type    = string
  default = "opstree-terraform-deploy"
}

variable "oidc_provider_arn" {
  type = string
}

variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "allowed_ref_sub" {
  description = "GitHub OIDC sub pattern (e.g. repo:opstree/Org-terraform-code:ref:refs/heads/main)."
  type        = string
}

variable "max_session_duration" {
  type    = number
  default = 3600
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
}