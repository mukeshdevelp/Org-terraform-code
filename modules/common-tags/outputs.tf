output "tags" {
  description = "Standard OpsTree tags for AWS resources."
  value       = merge(local.standard, var.extra_tags)
}