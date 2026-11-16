variable "region" {
  type = string
}

variable "transit_gateway_name" {
  type    = string
  default = "opstree-tgw-hub"
}

variable "ipam_pool_locale" {
  type    = string
  default = "ap-south-1"
}

variable "ipam_pools" {
  description = "Top-level IPAM pool CIDR allocations by team slug."
  type = map(object({
    cidr        = string
    description = string
  }))
}

variable "amazon_side_asn" {
  type    = number
  default = 64512
}

variable "tags" {
  type = map(string)
}