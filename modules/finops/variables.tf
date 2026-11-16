variable "cur_bucket_name" {
  type = string
}

variable "budgets" {
  description = "Per-account monthly cost budgets."
  type = map(object({
    limit_amount = string
    unit         = optional(string, "USD")
    subscribers  = list(string)
  }))
}

variable "cost_allocation_tags" {
  type    = list(string)
  default = ["Team", "Owner", "CostCenter", "Project", "Customer", "DataClassification", "Criticality"]
}

variable "tags" {
  type = map(string)
}