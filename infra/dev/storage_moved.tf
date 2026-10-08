moved {
  from = aws_s3_bucket.application
  to   = module.storage.aws_s3_bucket.application
}

moved {
  from = aws_s3_bucket_versioning.application
  to   = module.storage.aws_s3_bucket_versioning.application
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.application
  to   = module.storage.aws_s3_bucket_server_side_encryption_configuration.application
}

moved {
  from = aws_s3_bucket_public_access_block.application
  to   = module.storage.aws_s3_bucket_public_access_block.application
}

moved {
  from = aws_s3_bucket_policy.application
  to   = module.storage.aws_s3_bucket_policy.application
}

moved {
  from = aws_s3_object.status_artifact
  to   = module.storage.aws_s3_object.status_artifact
}

