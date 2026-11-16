# IAM Identity Center must be enabled manually or via Control Tower before applying.
# This module creates permission sets; account assignments are managed per team stack.

resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = each.value.session_duration

  tags = var.tags
}

# single sign in instance
data "aws_ssoadmin_instances" "this" {

}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for pair in flatten([
      for ps_name, cfg in var.permission_sets : [
        for policy_arn in cfg.managed_policies : {
          key         = "${ps_name}:${policy_arn}"
          ps_name     = ps_name
          policy_arn  = policy_arn
        }
      ]
    ]) : pair.key => pair
  }

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps_name].arn
}