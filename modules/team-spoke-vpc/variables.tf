variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "az_count" {
  type    = number
  default = 2
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = false
}

variable "transit_gateway_id" {
  type        = string
  default     = null
  description = "Attach spoke to centralized TGW when set."
}

variable "tags" {
  type = map(string)
}