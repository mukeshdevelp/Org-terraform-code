# Deploy in the management (organization) account.

resource "aws_guardduty_organization_admin_account" "this" {
  count = var.enable_guardduty ? 1 : 0

  admin_account_id = var.audit_account_id
}

resource "aws_securityhub_organization_admin_account" "this" {
  count = var.enable_security_hub ? 1 : 0

  admin_account_id = var.audit_account_id
}

resource "aws_config_organization_managed_rule" "encryption_baseline" {
  count = var.enable_config_org ? 1 : 0

  name            = "opstree-s3-encryption-enabled"
  rule_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  description     = "Organization-wide Config rule; extend with conformance packs in audit account"
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 24
}