# arn of  deployed role
output "deploy_role_arn" {
  description = "Assume-role ARN for Terraform in the member account."
  value       = "arn:${data.aws_partition.current.partition}:iam::${var.account_id}:role/${var.role_name}"
}