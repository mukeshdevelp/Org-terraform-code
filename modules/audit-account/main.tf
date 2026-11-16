terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws]
    }
  }
}

resource "aws_guardduty_detector" "this" {
  enable = true
  tags   = var.tags
}

resource "aws_guardduty_organization_configuration" "this" {
  auto_enable_organization_members = var.auto_enable_members ? "ALL" : "NONE"
  detector_id                      = aws_guardduty_detector.this.id
}

resource "aws_securityhub_account" "this" {
  enable_default_standards = true
}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.this]
}

data "aws_region" "current" {}

resource "aws_config_configuration_aggregator" "organization" {
  name = "opstree-org-aggregator"

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config_aggregator.arn
  }
}

resource "aws_iam_role" "config_aggregator" {
  name = "opstree-config-aggregator-org"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config_aggregator" {
  role       = aws_iam_role.config_aggregator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_accessanalyzer_analyzer" "org" {
  analyzer_name = "opstree-organization"
  type          = "ORGANIZATION"

  tags = var.tags
}