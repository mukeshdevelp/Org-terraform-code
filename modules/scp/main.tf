terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  policies_dir = "${path.module}/policies"
}

# Organization policy
resource "aws_organizations_policy" "this" {
  for_each = var.policy_attachments

  name        = each.key
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"

  content = each.value.source == "deny-unapproved-regions.json.tpl" ? templatefile(
    "${local.policies_dir}/${each.value.source}",
    {
      approved_regions_json = jsonencode(var.approved_regions)
    }
  ) : file("${local.policies_dir}/${each.value.source}")

  tags = var.tags
}

# organization policy attachment
resource "aws_organizations_policy_attachment" "this" {
  for_each = {
    for pair in flatten([
      for policy_name, cfg in var.policy_attachments : [
        for ou_id in cfg.target_ou_ids : {
          key         = "${policy_name}:${ou_id}"
          policy_name = policy_name
          ou_id       = ou_id
        }
      ]
    ]) : pair.key => pair
  }

  policy_id = aws_organizations_policy.this[each.value.policy_name].id
  target_id = each.value.ou_id
}