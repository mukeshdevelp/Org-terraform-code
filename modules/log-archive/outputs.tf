output "kms_key_arn" {
  value = aws_kms_key.logs.arn
}

output "bucket_ids" {
  value = { for k, b in aws_s3_bucket.this : k => b.id }
}

output "cloudtrail_bucket_id" {
  value = aws_s3_bucket.this["cloudtrail"].id
}

output "cloudtrail_bucket_arn" {
  value = aws_s3_bucket.this["cloudtrail"].arn
}