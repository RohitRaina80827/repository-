resource "aws_instance" "app" {
  count         = var.enable_compute ? 1 : 0
  ami           = "ami-0d27e0fb3bac4d724"
  instance_type = "t3.micro"

  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true

  iam_instance_profile = var.instance_profile_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tags = {
    Name = "terraform-status-lab-dev"
  }
}
