resource "aws_s3_object" "status_artifact" {
  bucket = aws_s3_bucket.application.id

  key = "artifacts/status.txt"

  source = "${path.root}/artifacts/status.txt"

  source_hash = filemd5(
    "${path.root}/artifacts/status.txt"
  )

  content_type = "text/plain"

  tags = var.tags

  depends_on = [
    aws_s3_bucket_versioning.application,
    aws_s3_bucket_server_side_encryption_configuration.application,
    aws_s3_bucket_public_access_block.application,
    aws_s3_bucket_policy.application
  ]
}

