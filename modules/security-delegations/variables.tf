variable "audit_account_id" {
  description = "OPT-SEC-AUDIT-001 account ID."
  type        = string
}

variable "enable_guardduty" {
  type    = bool
  default = true
}

variable "enable_security_hub" {
  type    = bool
  default = true
}

variable "enable_config_org" {
  type    = bool
  default = true
}

variable "config_s3_bucket_name" {
  description = "Central Config bucket in Log Archive (optional)."
  type        = string
  default     = null
}

variable "password_max_age_days" {
  description = "Maximum IAM password age in days (organization Config rule + management account policy)."
  type        = number
  default     = 30
}

variable "password_min_length" {
  type    = number
  default = 14
}

variable "access_key_max_age_days" {
  description = "Maximum IAM access key age in days (ACCESS_KEYS_ROTATED org Config rule)."
  type        = number
  default     = 30
}