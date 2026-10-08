
run "reject_invalid_environment" {
  command = plan

  variables {
    environment = "testing"
  }

  expect_failures = [
    var.environment,
  ]
}

