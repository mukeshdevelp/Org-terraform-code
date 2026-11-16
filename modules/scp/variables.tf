variable "organization_root_id" {
  description = "Organizations root ID (r-xxxx)."
  type        = string
}

variable "approved_regions" {
  description = "AWS Regions where member accounts may operate."
  type        = list(string)
}

variable "policy_attachments" {
  description = "Map of SCP definitions and target OU IDs."
  type = map(object({
    description   = string
    source        = string
    target_ou_ids = list(string)
    template_vars = optional(map(string), {})
  }))
}

variable "tags" {
  description = "Tags applied to organization policies where supported."
  type        = map(string)
  default     = {}
}