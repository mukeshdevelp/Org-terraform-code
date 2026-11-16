output "account_ids" {
  description = "Vendored account IDs (merge with var.account_ids for provider configuration)."
  value       = local.account_ids
}

output "organization_id" {
  value = local.organization_id
}

output "root_id" {
  value = var.enable_organization ? module.organization[0].root_id : null
}

output "organizational_unit_ids" {
  value = var.enable_organization ? module.organization[0].organizational_unit_ids : {}
}

output "scp_policy_ids" {
  value = var.enable_organization ? module.scp[0].policy_ids : {}
}

output "state_bucket_name" {
  value = var.enable_bootstrap ? module.bootstrap[0].state_bucket_name : null
}

output "log_archive_cloudtrail_bucket" {
  value = var.enable_log_archive ? module.log_archive[0].cloudtrail_bucket_id : null
}

output "log_archive_kms_key_arn" {
  value = var.enable_log_archive ? module.log_archive[0].kms_key_arn : null
}

output "transit_gateway_id" {
  value = var.enable_network ? module.network_hub[0].transit_gateway_id : null
}