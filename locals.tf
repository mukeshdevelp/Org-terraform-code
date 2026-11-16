module "common_tags" {
  source = "./modules/common-tags"

  environment         = "organization"
  team                = "platform"
  owner               = var.owner_email
  cost_center         = var.cost_center
  project             = "landing-zone"
  data_classification = "internal"
  criticality         = "high"
}

locals {
  organizational_units = {
    security        = { name = "Security", parent = "root" }
    aws_core        = { name = "AWS-Core", parent = "root" }
    observability   = { name = "Observability", parent = "root" }
    coe             = { name = "COE", parent = "root" }
    buildpiper      = { name = "BuildPiper", parent = "root" }
    sandbox         = { name = "Sandbox", parent = "root" }
    other_teams     = { name = "Other Teams", parent = "root" }
    quarantine      = { name = "Quarantine", parent = "root" }
    suspended       = { name = "Suspended", parent = "root" }
    policy_staging  = { name = "Policy Staging", parent = "root" }
  }

  default_member_accounts = {
    log_archive = {
      name      = "OPT-SEC-LOG-001"
      email     = "CHANGE_ME+log-archive@opstree.com"
      parent_ou = "security"
      tags      = { Plane = "log-archive", Team = "security" }
    }
    audit = {
      name      = "OPT-SEC-AUDIT-001"
      email     = "CHANGE_ME+audit@opstree.com"
      parent_ou = "security"
      tags      = { Plane = "security-tooling", Team = "security" }
    }
    backup = {
      name      = "OPT-SEC-BKP-001"
      email     = "CHANGE_ME+backup@opstree.com"
      parent_ou = "security"
      tags      = { Plane = "backup", Team = "security" }
    }
    network = {
      name      = "OPT-INF-NET-001"
      email     = "CHANGE_ME+network@opstree.com"
      parent_ou = "aws_core"
      tags      = { Plane = "network", Team = "aws-core" }
    }
    shared = {
      name      = "OPT-INF-SHARED-001"
      email     = "CHANGE_ME+shared@opstree.com"
      parent_ou = "aws_core"
      tags      = { Plane = "shared-services", Team = "aws-core" }
    }
    awscore = {
      name      = "OPT-TEAM-AWSCORE-001"
      email     = "CHANGE_ME+awscore@opstree.com"
      parent_ou = "aws_core"
      tags      = { Team = "aws-core" }
    }
    coe = {
      name      = "OPT-TEAM-COE-001"
      email     = "CHANGE_ME+coe@opstree.com"
      parent_ou = "coe"
      tags      = { Team = "coe" }
    }
    observability = {
      name      = "OPT-TEAM-OBS-001"
      email     = "CHANGE_ME+observability@opstree.com"
      parent_ou = "observability"
      tags      = { Team = "observability" }
    }
    buildpiper = {
      name      = "OPT-TEAM-BP-001"
      email     = "CHANGE_ME+buildpiper@opstree.com"
      parent_ou = "buildpiper"
      tags      = { Team = "buildpiper" }
    }
    sandbox = {
      name      = "OPT-SBX-ENG-001"
      email     = "CHANGE_ME+sandbox@opstree.com"
      parent_ou = "sandbox"
      tags      = { Team = "engineering", Environment = "sandbox" }
    }
    other_teams = {
      name      = "OPT-TEAM-XXX-001"
      email     = "CHANGE_ME+otherteams@opstree.com"
      parent_ou = "other_teams"
      tags      = { Team = "other" }
    }
  }

  member_accounts_input     = length(var.member_accounts) > 0 ? var.member_accounts : local.default_member_accounts
  member_accounts_to_create = var.create_member_accounts ? local.member_accounts_input : {}

  # Merge vendored IDs with optional overrides from tfvars (for provider aliases and downstream modules).
  vendored_account_ids = try(module.organization[0].account_ids, {})
  account_ids          = merge(local.vendored_account_ids, var.account_ids)

  organization_id = try(module.organization[0].organization_id, var.organization_id)
}