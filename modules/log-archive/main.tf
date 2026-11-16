terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws]
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_kms_key" "logs" {
  description             = "OpsTree centralized log archive encryption"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_key_deletion_window

  tags = merge(var.tags, {
    "ops-tree:plane" = "log-archive"
  })
}

resource "aws_kms_alias" "logs" {
  name          = "alias/opstree-log-archive"
  target_key_id = aws_kms_key.logs.key_id
}

locals {
  buckets = {
    cloudtrail = {
      suffix      = "cloudtrail"
      object_lock = true
    }
    config = {
      suffix      = "config"
      object_lock = true
    }
    flowlogs = {
      suffix      = "vpc-flow-logs"
      object_lock = true
    }
    resolver = {
      suffix      = "route53-resolver"
      object_lock = true
    }
    cur = {
      suffix      = "cur"
      object_lock = false
    }
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets

  bucket = "${var.bucket_name_prefix}-${each.value.suffix}"

  object_lock_enabled = each.value.object_lock

  tags = merge(var.tags, {
    "ops-tree:plane" = "log-archive"
    Purpose          = each.key
  })
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.logs.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  for_each = { for k, v in local.buckets : k => v if v.object_lock }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    default_retention {
      mode = var.object_lock_mode
      days = var.object_lock_days
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_retention_years * 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  for_each = aws_s3_bucket.this

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:*"]
    resources = [each.value.arn, "${each.value.arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  policy = data.aws_iam_policy_document.deny_insecure_transport[each.key].json
}