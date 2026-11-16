resource "aws_cloudtrail" "org" {
  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket_name
  kms_key_id                    = var.kms_key_arn
  is_organization_trail         = var.is_organization_trail
  is_multi_region_trail           = true
  include_global_service_events   = var.include_global_service_events
  enable_log_file_validation      = var.enable_log_file_validation
  enable_logging                  = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = merge(var.tags, {
    "ops-tree:protected" = "organization-trail"
  })
}