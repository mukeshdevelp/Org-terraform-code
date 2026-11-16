variable "root_id" {
  description = "Organization root ID for tag policy attachment."
  type        = string
}

variable "mandatory_tag_keys" {
  type        = list(string)
  default = [
    "Team",
    "Owner",
    "CostCenter",
    "Project",
    "DataClassification",
    "Criticality",
    "Environment",
    "ManagedBy",
  ]
}

variable "tags" {
  type    = map(string)
  default = {}
}