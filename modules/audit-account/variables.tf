variable "finding_export_bucket" {
  description = "Optional S3 bucket for Security Hub findings export."
  type        = string
  default     = null
}

variable "auto_enable_members" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
}