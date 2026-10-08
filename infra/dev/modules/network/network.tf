data "aws_availability_zones" "network" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

resource "aws_vpc" "network" {
  cidr_block = "10.20.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.network_tags, {
    Name = "${local.network_name}-vpc"
  })

  lifecycle {
    precondition {
      condition = alltrue([
        for az in values(var.availability_zones) :
        contains(data.aws_availability_zones.network.names, az)
      ])

      error_message = "Both zones must be available in the configured AWS region."
    }
  }
}

resource "aws_subnet" "network" {
  for_each = local.network_subnets

  vpc_id            = aws_vpc.network.id
  cidr_block        = each.value.cidr_block
  availability_zone = var.availability_zones[each.value.az_key]

  map_public_ip_on_launch = false

  tags = merge(local.network_tags, {
    Name = "${local.network_name}-${each.key}"
    Tier = each.value.tier
  })
}

resource "aws_internet_gateway" "network" {
  vpc_id = aws_vpc.network.id

  tags = merge(local.network_tags, {
    Name = "${local.network_name}-igw"
  })
}
