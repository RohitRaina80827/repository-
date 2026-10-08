
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

