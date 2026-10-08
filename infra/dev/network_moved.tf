moved {
  from = aws_vpc.network
  to   = module.network.aws_vpc.network
}

moved {
  from = aws_subnet.network
  to   = module.network.aws_subnet.network
}

moved {
  from = aws_internet_gateway.network
  to   = module.network.aws_internet_gateway.network
}

moved {
  from = aws_route_table.public
  to   = module.network.aws_route_table.public
}

moved {
  from = aws_route.public_internet
  to   = module.network.aws_route.public_internet
}

moved {
  from = aws_route_table.private
  to   = module.network.aws_route_table.private
}

moved {
  from = aws_route_table_association.public
  to   = module.network.aws_route_table_association.public
}

moved {
  from = aws_route_table_association.private
  to   = module.network.aws_route_table_association.private
}

