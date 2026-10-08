resource "aws_security_group" "core" {
  name        = "${local.security_name}-core"
  description = "No inbound access; outbound HTTPS only"

  vpc_id = module.network.vpc_id

  ingress = []

  egress {
    description = "HTTPS management and artifact downloads"

    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.network_tags, {
    Name = "${local.security_name}-core"
  })
}
