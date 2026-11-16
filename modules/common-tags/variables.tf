variable "organization" {
  description = "Organization name used in standard tags."
  type        = string
  default     = "OpsTree"
}

variable "environment" {
  description = "Environment label (e.g. prod, shared, security)."
  type        = string
}

variable "team" {
  description = "Owning team for the resource."
  type        = string
  default     = "platform"
}

variable "owner" {
  description = "Accountable owner contact (email)."
  type        = string
}

variable "cost_center" {
  description = "Finance cost center code."
  type        = string
}

variable "project" {
  description = "Project or capability name."
  type        = string
  default     = "landing-zone"
}

variable "data_classification" {
  description = "Data classification tier."
  type        = string
  default     = "internal"
}

variable "criticality" {
  description = "Business criticality tier."
  type        = string
  default     = "high"
}

variable "extra_tags" {
  description = "Additional tags merged into the standard set."
  type        = map(string)
  default     = {}
}