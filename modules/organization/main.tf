terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_organizations_organization" "this" {
  count = var.create_organization ? 1 : 0

  aws_service_access_principals = var.aws_service_access_principals
  enabled_policy_types          = var.enabled_policy_types
  feature_set                   = "ALL"
}

data "aws_organizations_organization" "current" {
  depends_on = [aws_organizations_organization.this]
}

locals {
  organization_id = var.create_organization ? aws_organizations_organization.this[0].id : var.organization_id
  root_id         = data.aws_organizations_organization.current.roots[0].id
}
# organization unit 
resource "aws_organizations_organizational_unit" "this" {
  for_each = var.organizational_units

  name = each.value.name
  parent_id = each.value.parent == "root" ? local.root_id : aws_organizations_organizational_unit.this[each.value.parent].id
}

# organization resource
resource "aws_organizations_account" "this" {
  for_each = var.member_accounts

  name              = each.value.name
  email             = each.value.email
  role_name         = each.value.role_name
  parent_id         = each.value.parent_ou == "root" ? local.root_id : aws_organizations_organizational_unit.this[each.value.parent_ou].id
  close_on_deletion = var.close_on_deletion

  tags = merge(var.tags, each.value.tags, {
    AccountAlias = each.key
    Name         = each.value.name
  })
}