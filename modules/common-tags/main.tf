locals {
  standard = {
    Organization         = var.organization
    Environment          = var.environment
    ManagedBy            = "terraform"
    Team                 = var.team
    Owner                = var.owner
    CostCenter           = var.cost_center
    Project              = var.project
    DataClassification   = var.data_classification
    Criticality          = var.criticality
  }
}

output "tags" {
  description = "Standard OpsTree tags for AWS resources."
  value       = merge(local.standard, var.extra_tags)
}