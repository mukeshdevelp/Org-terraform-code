variable "identity_store_id" {
  description = "Optional existing Identity Store ID from IAM Identity Center."
  type        = string
  default     = null
}

variable "permission_sets" {
  description = "Permission sets to create."
  type = map(object({
    description      = string
    session_duration = optional(string, "PT4H")
    managed_policies = optional(list(string), [])
    inline_policy    = optional(string)
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}