variable "create_organization" {
  description = "Create a new AWS Organization. Set false when importing an existing org."
  type        = bool
  default     = true
}

variable "organization_id" {
  description = "Existing organization ID when create_organization is false."
  type        = string
  default     = null
}

variable "aws_service_access_principals" {
  description = "Service principals enabled for the organization."
  type        = list(string)
  default = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com",
    "ram.amazonaws.com",
    "backup.amazonaws.com",
    "iam.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
    "account.amazonaws.com",
  ]
}

variable "enabled_policy_types" {
  description = "Organization policy types to enable."
  type        = list(string)
  default = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
    "BACKUP_POLICY",
  ]
}

variable "organizational_units" {
  description = "OU definitions keyed by stable slug."
  type = map(object({
    name     = string
    parent   = string # slug of parent OU or \"root\"
  }))
}

variable "member_accounts" {
  description = "Accounts to create or register. Emails must be globally unique."
  type = map(object({
    name      = string
    email     = string
    role_name = optional(string, "OrganizationAccountAccessRole")
    parent_ou = string # OU slug
    tags      = optional(map(string), {})
  }))
}

variable "close_on_deletion" {
  description = "Close member accounts when removed from Terraform (use with caution)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for supported organization resources."
  type        = map(string)
  default     = {}
}