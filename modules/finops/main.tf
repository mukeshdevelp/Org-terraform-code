resource "aws_cur_report_definition" "org" {
  report_name                = "opstree-cur2"
  time_unit                  = "HOURLY"
  format                     = "Parquet"
  compression                = "Parquet"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = var.cur_bucket_name
  s3_region                  = data.aws_region.current.name
  s3_prefix                  = "cur2"
  report_versioning          = "OVERWRITE_REPORT"
  refresh_closed_reports     = true

  depends_on = [aws_s3_bucket_policy.cur]
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cur_bucket" {
  statement {
    sid    = "AllowBillingReports"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["billingreports.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${var.cur_bucket_name}",
      "arn:aws:s3:::${var.cur_bucket_name}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "cur" {
  bucket = var.cur_bucket_name
  policy = data.aws_iam_policy_document.cur_bucket.json
}

resource "aws_ce_cost_allocation_tag" "this" {
  for_each = toset(var.cost_allocation_tags)

  tag_key = each.value
  status  = "Active"
}

resource "aws_budgets_budget" "account" {
  for_each = var.budgets

  name         = "opstree-${each.key}"
  budget_type  = "COST"
  limit_amount = each.value.limit_amount
  limit_unit   = each.value.unit
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "LinkedAccount"
    values = [each.key]
  }

  dynamic "notification" {
    for_each = each.value.subscribers
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 80
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = [notification.value]
    }
  }
}