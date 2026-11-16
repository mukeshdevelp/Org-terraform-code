output "organization_id" {
  value = local.organization_id
}

output "root_id" {
  value = local.root_id
}

output "organizational_unit_ids" {
  value = { for k, ou in aws_organizations_organizational_unit.this : k => ou.id }
}

output "account_ids" {
  value = { for k, a in aws_organizations_account.this : k => a.id }
}

output "account_arns" {
  value = { for k, a in aws_organizations_account.this : k => a.arn }
}