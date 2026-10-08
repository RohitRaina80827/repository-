resource "aws_route_table" "public" {
  vpc_id = aws_vpc.network.id

  tags = merge(local.network_tags, {
    Name = "${local.network_name}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.network.id
}
resource "aws_route_table_association" "public" {
  for_each = {
    for name, config in local.network_subnets :
    name => config
    if config.tier == "public"
  }

  subnet_id      = aws_subnet.network[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = tomap(var.availability_zones)

  vpc_id = aws_vpc.network.id

  tags = merge(local.network_tags, {
    Name = "${local.network_name}-private-${each.key}-rt"
  })
}

resource "aws_route_table_association" "private" {
  for_each = {
    for name, config in local.network_subnets :
    name => config
    if config.tier == "private"
  }

  subnet_id = aws_subnet.network[each.key].id

  route_table_id = aws_route_table.private[
    each.value.az_key
  ].id
}
