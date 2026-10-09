mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b"]
    }
  }
}


run "reject_invalid_environment" {
  command = plan

  variables {
    environment = "testing"
  }

  expect_failures = [
    var.environment,
  ]
}

