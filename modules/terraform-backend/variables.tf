variable "bucket_name" {
  type = string
}

variable "dynamodb_table_name" {
  type    = string
  default = "opstree-terraform-locks"
}

variable "kms_alias" {
  type    = string
  default = "alias/opstree-terraform-state"
}

variable "tags" {
  type = map(string)
}