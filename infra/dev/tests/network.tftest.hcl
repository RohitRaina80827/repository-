mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b"]
    }
  }
}


run "reject_duplicates" {
  command = plan

  variables {
    availability_zones = {
      a = "us-east-1a"
      b = "us-east-1a"
    }
  }

  expect_failures = [var.availability_zones]
}

