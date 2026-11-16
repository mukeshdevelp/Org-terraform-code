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

