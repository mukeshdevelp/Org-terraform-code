output "policy_ids" {
  description = "Map of SCP name to policy ID."
  value       = { for k, p in aws_organizations_policy.this : k => p.id }
}