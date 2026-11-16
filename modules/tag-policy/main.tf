locals {
  tag_policy = {
    tags = {
      for key in var.mandatory_tag_keys : key => {
        tag_key = {
          "@@assign" = key
        }
        enforced_for = {
          "@@assign" = ["ec2:instance", "ec2:volume", "s3:bucket", "rds:db"]
        }
      }
    }
  }
}

resource "aws_organizations_policy" "tag" {
  name        = "opstree-mandatory-tags"
  description = "OpsTree mandatory cost and governance tags"
  type        = "TAG_POLICY"
  content     = jsonencode(local.tag_policy)
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "tag_root" {
  policy_id = aws_organizations_policy.tag.id
  target_id = var.root_id
}