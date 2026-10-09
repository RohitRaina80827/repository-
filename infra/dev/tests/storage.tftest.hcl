mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b"]
    }
  }
}


run "validate_s3_public_access_protection" {
  command = plan

  assert {
    condition = (
      module.storage.security_details.block_public_acls == true &&
      module.storage.security_details.block_public_policy == true &&
      module.storage.security_details.ignore_public_acls == true &&
      module.storage.security_details.restrict_public_buckets == true
    )

    error_message = "S3 public-access protection must have all four blocking controls enabled."
  }
}

run "validate_s3_encryption" {
  command = plan

  assert {
    condition = module.storage.sse_algorithm == "AES256"

    error_message = "S3 application bucket must use AES256 server-side encryption."
  }
}

run "regression_s3_encryption_output_is_evaluable" {
  command = plan

  assert {
    condition = module.storage.sse_algorithm != null

    error_message = "S3 encryption output must remain safely evaluable when the encryption rule is represented as a set."
  }
}

