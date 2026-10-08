output "vpc_id" {
  value = aws_vpc.network.id
}

output "public_subnet_ids" {
  value = {
    for name, subnet in aws_subnet.network :
    name => subnet.id
    if local.network_subnets[name].tier == "public"
  }
}

output "private_subnet_ids" {
  value = {
    for name, subnet in aws_subnet.network :
    name => subnet.id
    if local.network_subnets[name].tier == "private"
  }
}

output "network_route_table_ids" {
  value = {
    public = aws_route_table.public.id

    private = {
      for name, table in aws_route_table.private :
      name => table.id
    }
  }
}

output "subnet_details" {
  value = {
    for name, subnet in aws_subnet.network :
    name => {
      availability_zone       = subnet.availability_zone
      map_public_ip_on_launch = subnet.map_public_ip_on_launch
      tier                    = local.network_subnets[name].tier
    }
  }
}

