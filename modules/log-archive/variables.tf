variable "bucket_name_prefix" {
  description = "Prefix for central log buckets (must be globally unique)."
  type        = string
}

variable "kms_key_deletion_window" {
  type    = number
  default = 30
}

variable "object_lock_mode" {
  description = "GOVERNANCE or COMPLIANCE."
  type        = string
  default     = "GOVERNANCE"
}

variable "object_lock_days" {
  type    = number
  default = 365
}

variable "log_retention_years" {
  type    = number
  default = 7
}

variable "organization_id" {
  type = string
}

variable "tags" {
  type = map(string)
}