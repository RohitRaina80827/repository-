

run "validate_root_volume_encrypted" {
  command = plan

  variables {
    enable_compute = true
  }

  assert {
    condition = (
      module.compute.security_details.root_volume_encrypted == true
    )


    error_message = "EC2 root volume must be encrypted."
  }
}

run "validate_optional_compute_output" {
  command = plan

  variables {
    enable_compute = false
  }

  assert {
    condition = module.compute.status_instance_id == null

    error_message = "status_instance_id must be null when compute is disabled."
  }
}

run "validate_imdsv2_required" {
  command = plan

  variables {
    enable_compute = true
  }

  assert {
    condition = (
      module.compute.security_details.imds_http_tokens == "required"
    )

    error_message = "EC2 instances must require IMDSv2."
  }
}

