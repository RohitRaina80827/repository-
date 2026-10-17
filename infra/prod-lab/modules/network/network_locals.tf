locals {
  network_name = var.network_name

  network_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }

  network_subnets = {
    public_a = {
      cidr_block = "10.30.1.0/24"
      az_key     = "a"
      tier       = "public"
    }

    public_b = {
      cidr_block = "10.30.2.0/24"
      az_key     = "b"
      tier       = "public"
    }

    private_a = {
      cidr_block = "10.30.11.0/24"
      az_key     = "a"
      tier       = "private"
    }

    private_b = {
      cidr_block = "10.30.12.0/24"
      az_key     = "b"
      tier       = "private"
    }
  }
}
