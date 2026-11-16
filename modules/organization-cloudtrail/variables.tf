variable "trail_name" {
  type    = string
  default = "opstree-org-trail"
}

variable "s3_bucket_name" {
  type = string
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "Optional KMS key for CloudTrail encryption."
}

variable "is_organization_trail" {
  type    = bool
  default = true
}

variable "include_global_service_events" {
  type    = bool
  default = true
}

variable "enable_log_file_validation" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
}