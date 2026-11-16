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