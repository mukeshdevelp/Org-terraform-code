output "state_bucket_name" {
  value = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  value = aws_s3_bucket.state.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.locks.name
}

output "kms_key_arn" {
  value = aws_kms_key.state.arn
}