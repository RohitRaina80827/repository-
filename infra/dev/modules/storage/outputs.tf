output "bucket_name" {
  description = "Name of the application artifact bucket."
  value       = aws_s3_bucket.application.bucket
}

output "bucket_arn" {
  description = "ARN of the application artifact bucket."
  value       = aws_s3_bucket.application.arn
}

output "artifact_key" {
  description = "Object key of the status artifact."
  value       = aws_s3_object.status_artifact.key
}

output "security_details" {
  value = {
    block_public_acls       = aws_s3_bucket_public_access_block.application.block_public_acls
    block_public_policy     = aws_s3_bucket_public_access_block.application.block_public_policy
    ignore_public_acls      = aws_s3_bucket_public_access_block.application.ignore_public_acls
    restrict_public_buckets = aws_s3_bucket_public_access_block.application.restrict_public_buckets
  }
}

output "sse_algorithm" {
  value = one([
    for rule in aws_s3_bucket_server_side_encryption_configuration.application.rule :
    one([
      for config in rule.apply_server_side_encryption_by_default :
      config.sse_algorithm
    ])
  ])
}

