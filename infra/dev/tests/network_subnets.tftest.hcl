mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b"]
    }
  }
}
run "validate_subnet_count" {
  command = plan

  assert {
    condition = (
      length(values(module.network.public_subnet_ids)) == 2 &&
      length(values(module.network.private_subnet_ids)) == 2
    )

    error_message = "Network must contain exactly 2 public and 2 private subnets."
  }
}

run "validate_subnet_zone_distribution" {
  command = plan

  assert {
    condition = (
      module.network.subnet_details["public_a"].availability_zone ==
      module.network.subnet_details["private_a"].availability_zone &&
      module.network.subnet_details["public_b"].availability_zone ==
      module.network.subnet_details["private_b"].availability_zone &&
      module.network.subnet_details["public_a"].availability_zone !=
      module.network.subnet_details["public_b"].availability_zone
    )

    error_message = "Public and private subnets must be paired across two distinct availability zones."
  }
}

run "validate_private_subnet_public_ip_disabled" {
  command = plan

  assert {
    condition = alltrue([
      for name, subnet in module.network.subnet_details :
      subnet.map_public_ip_on_launch == false
      if subnet.tier == "private"
    ])

    error_message = "Private subnets must not automatically assign public IPv4 addresses."
  }
}

