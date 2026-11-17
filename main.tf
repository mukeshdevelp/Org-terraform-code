# -----------------------------------------------------------------------------
# Bootstrap — Shared Services (optional; run first before remote backend)
# -----------------------------------------------------------------------------

module "bootstrap" {
  count  = var.enable_bootstrap ? 1 : 0
  source = "./modules/terraform-backend"

  providers = {
    aws = aws.shared
  }

  bucket_name = var.state_bucket_name
  tags        = module.common_tags.tags
}

# -----------------------------------------------------------------------------
# Organization — management account
# -----------------------------------------------------------------------------

module "organization" {
  count  = var.enable_organization ? 1 : 0
  source = "./modules/organization"

  create_organization  = var.create_organization
  organization_id      = var.organization_id
  organizational_units = local.organizational_units
  member_accounts      = local.member_accounts_to_create
  tags                 = module.common_tags.tags
}

module "tag_policy" {
  count   = var.enable_organization ? 1 : 0
  source  = "./modules/tag-policy"
  root_id = module.organization[0].root_id
  tags    = module.common_tags.tags
}

data "aws_organizations_policy" "fullaws" {
  count     = var.enable_organization ? 1 : 0
  policy_id = "p-FullAWSAccess"
}

resource "aws_organizations_policy_attachment" "fullaws_root" {
  count     = var.enable_organization ? 1 : 0
  policy_id = data.aws_organizations_policy.fullaws[0].id
  target_id = module.organization[0].root_id
}

resource "aws_organizations_policy_attachment" "fullaws_ous" {
  for_each = var.enable_organization ? toset(values(module.organization[0].organizational_unit_ids)) : toset([])

  policy_id = data.aws_organizations_policy.fullaws[0].id
  target_id = each.value
}

module "scp" {
  count  = var.enable_organization ? 1 : 0
  source = "./modules/scp"

  organization_root_id = module.organization[0].root_id
  approved_regions     = var.approved_regions
  tags                 = module.common_tags.tags

  policy_attachments = {
    deny-leave-organization = {
      description   = "Prevent accounts from leaving the organization"
      source        = "deny-leave-organization.json"
      target_ou_ids = [module.organization[0].root_id]
    }
    require-mfa = {
      description   = "Require MFA for interactive and API access (inherited by all member accounts)"
      source        = "require-mfa.json"
      target_ou_ids = [module.organization[0].root_id]
    }
    protect-password-policy = {
      description   = "Block weakening account password policy; pair with Config/Terraform 30-day max age"
      source        = "protect-password-policy.json"
      target_ou_ids = [module.organization[0].root_id]
    }
    protect-kms-key-rotation = {
      description   = "Prevent disabling KMS automatic key rotation"
      source        = "protect-kms-key-rotation.json"
      target_ou_ids = [module.organization[0].root_id]
    }
    protect-iam-access-keys = {
      description   = "Protect IAM access key lifecycle; pair with Config 30-day access key rotation"
      source        = "protect-iam-access-keys.json"
      target_ou_ids = [module.organization[0].root_id]
    }
    deny-unapproved-regions = {
      description   = "Restrict API activity to approved regions (Sandbox OU excluded)"
      source        = "deny-unapproved-regions.json.tpl"
      target_ou_ids = local.non_sandbox_ou_ids
    }
    protect-security-services = {
      description   = "Protect organization security services and trail"
      source        = "protect-security-services.json"
      target_ou_ids = values(module.organization[0].organizational_unit_ids)
    }
    protect-log-archive = {
      description   = "Protect centralized evidence buckets and keys"
      source        = "protect-log-archive.json"
      target_ou_ids = [module.organization[0].organizational_unit_ids["security"]]
    }
    protect-network-hub = {
      description   = "Restrict changes to network plane resources"
      source        = "protect-network-hub.json"
      target_ou_ids = [module.organization[0].organizational_unit_ids["aws_core"]]
    }
    sandbox-restrictions = {
      description   = "Sandbox guardrails"
      source        = "sandbox-restrictions.json"
      target_ou_ids = [module.organization[0].organizational_unit_ids["sandbox"]]
    }
    quarantine = {
      description   = "Quarantine unassessed accounts"
      source        = "quarantine.json"
      target_ou_ids = [module.organization[0].organizational_unit_ids["quarantine"]]
    }
    suspended = {
      description   = "Suspended accounts deny-by-default"
      source        = "suspended.json"
      target_ou_ids = [module.organization[0].organizational_unit_ids["suspended"]]
    }
  }
}

module "security_delegations" {
  count  = var.enable_organization && contains(keys(local.account_ids), var.delegated_audit_account_key) ? 1 : 0
  source = "./modules/security-delegations"

  audit_account_id = local.account_ids[var.delegated_audit_account_key]
}

module "identity_center" {
  count  = var.enable_organization ? 1 : 0
  source = "./modules/iam-identity-center"

  permission_sets = {
    PlatformAdmin = {
      description      = "Break-glass platform administration"
      session_duration = "PT1H"
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
    TeamOwner = {
      description      = "Team account owner"
      session_duration = "PT4H"
      managed_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    }
    ReadOnly = {
      description      = "Read-only across assigned accounts"
      session_duration = "PT8H"
      managed_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
    SecurityAuditor = {
      description      = "Security and compliance read access"
      session_duration = "PT4H"
      managed_policies = ["arn:aws:iam::aws:policy/SecurityAudit"]
    }
  }

  tags = module.common_tags.tags
}

module "organization_cloudtrail" {
  count  = var.enable_organization_cloudtrail ? 1 : 0
  source = "./modules/organization-cloudtrail"

  s3_bucket_name = var.cloudtrail_s3_bucket_name
  kms_key_arn    = var.cloudtrail_kms_key_arn
  tags           = module.common_tags.tags
}

# -----------------------------------------------------------------------------
# Log Archive
# -----------------------------------------------------------------------------

module "log_archive" {
  count  = var.enable_log_archive ? 1 : 0
  source = "./modules/log-archive"

  providers = {
    aws = aws.log_archive
  }

  bucket_name_prefix = var.bucket_name_prefix
  organization_id    = local.organization_id
  tags               = module.common_tags.tags
}

data "aws_iam_policy_document" "cloudtrail_log_bucket" {
  count = var.enable_log_archive ? 1 : 0

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [module.log_archive[0].cloudtrail_bucket_arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${module.log_archive[0].cloudtrail_bucket_arn}/AWSLogs/${local.organization_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count = var.enable_log_archive ? 1 : 0

  provider = aws.log_archive
  bucket   = module.log_archive[0].cloudtrail_bucket_id
  policy   = data.aws_iam_policy_document.cloudtrail_log_bucket[0].json
}

# -----------------------------------------------------------------------------
# Audit
# -----------------------------------------------------------------------------

module "audit" {
  count  = var.enable_audit ? 1 : 0
  source = "./modules/audit-account"

  providers = {
    aws = aws.audit
  }

  tags = module.common_tags.tags
}

# -----------------------------------------------------------------------------
# Network hub
# -----------------------------------------------------------------------------

module "network_hub" {
  count  = var.enable_network ? 1 : 0
  source = "./modules/network-hub"

  providers = {
    aws = aws.network
  }

  region     = var.primary_region
  ipam_pools = var.ipam_pools
  tags       = module.common_tags.tags
}

# -----------------------------------------------------------------------------
# FinOps — management account
# -----------------------------------------------------------------------------

module "finops" {
  count  = var.enable_finops ? 1 : 0
  source = "./modules/finops"

  cur_bucket_name = var.cur_bucket_name
  budgets = {
    for account_key, cfg in var.account_budgets :
    local.account_ids[account_key] => {
      limit_amount = cfg.limit_amount
      subscribers  = cfg.subscribers
    }
    if contains(keys(local.account_ids), account_key)
  }
  tags = module.common_tags.tags
}