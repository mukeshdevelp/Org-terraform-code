variable "account_id" {
  description = "12-digit member account ID (from organization stack output)."
  type        = string
}

variable "role_name" {
  description = "Cross-account access role created when the account joined the org."
  type        = string
  default     = "OrganizationAccountAccessRole"
}