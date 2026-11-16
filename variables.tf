# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

variable "primary_region" {
  type    = string
  default = "ap-south-1"
}

variable "approved_regions" {
  type    = list(string)
  default = ["ap-south-1"]
}

variable "owner_email" {
  type    = string
  default = "platform@opstree.com"
}

variable "cost_center" {
  type    = string
  default = "CC-1042"
}

variable "organization_access_role_name" {
  type    = string
  default = "OrganizationAccountAccessRole"
}

# -----------------------------------------------------------------------------
# Layer toggles
# -----------------------------------------------------------------------------

variable "enable_bootstrap" {
  description = "Terraform state backend in Shared Services account."
  type        = bool
  default     = false
}

variable "enable_organization" {
  type    = bool
  default = true
}

variable "enable_log_archive" {
  type    = bool
  default = false
}

variable "enable_audit" {
  type    = bool
  default = false
}

variable "enable_network" {
  type    = bool
  default = false
}

variable "enable_finops" {
  type    = bool
  default = false
}

variable "enable_organization_cloudtrail" {
  type    = bool
  default = false
}

# -----------------------------------------------------------------------------
# Organization
# -----------------------------------------------------------------------------

variable "create_organization" {
  type    = bool
  default = true
}

variable "organization_id" {
  type    = string
  default = null
}

variable "create_member_accounts" {
  description = "Vend accounts from management account (email only). Set false if using Control Tower Account Factory."
  type        = bool
  default     = true
}

variable "member_accounts" {
  description = "Account catalog keyed by slug; only email must be unique at create time."
  type = map(object({
    name      = string
    email     = string
    parent_ou = string
    role_name = optional(string, "OrganizationAccountAccessRole")
    tags      = optional(map(string), {})
  }))
  default = {}
}

variable "delegated_audit_account_key" {
  type    = string
  default = "audit"
}

variable "account_ids" {
  description = "AWS-assigned IDs keyed by member_accounts slug. Copy from output after first apply, or leave {} until accounts exist."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Bootstrap / Log Archive / FinOps
# -----------------------------------------------------------------------------

variable "state_bucket_name" {
  type    = string
  default = ""
}

variable "bucket_name_prefix" {
  type    = string
  default = "opstree-logs"
}

variable "cloudtrail_s3_bucket_name" {
  type    = string
  default = ""
}

variable "cloudtrail_kms_key_arn" {
  type    = string
  default = ""
}

variable "cur_bucket_name" {
  type    = string
  default = ""
}

variable "account_budgets" {
  type = map(object({
    limit_amount = string
    subscribers  = list(string)
  }))
  default = {}
}

variable "ipam_pools" {
  type = map(object({
    cidr        = string
    description = string
  }))
  default = {
    network-services = { cidr = "10.0.0.0/16", description = "Network hub reserved" }
    shared-services  = { cidr = "10.5.0.0/16", description = "Shared services" }
    coe              = { cidr = "10.16.0.0/16", description = "COE team" }
    observability    = { cidr = "10.17.0.0/16", description = "Observability team" }
    awscore          = { cidr = "10.18.0.0/16", description = "AWS-Core team" }
    buildpiper       = { cidr = "10.19.0.0/16", description = "BuildPiper" }
    other-teams      = { cidr = "10.20.0.0/16", description = "Future teams" }
    customer         = { cidr = "10.10.0.0/16", description = "Customer pool" }
  }
}