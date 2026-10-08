locals {
  network_name = "terraform-status-lab-dev"

  network_tags = {
    Project     = "terraform-status-lab"
    Environment = "dev"
    Owner       = var.owner
    ManagedBy   = "terraform"
  }

  network_subnets = {
    public_a = {
      cidr_block = "10.20.1.0/24"
      az_key     = "a"
      tier       = "public"
    }

    public_b = {
      cidr_block = "10.20.2.0/24"
      az_key     = "b"
      tier       = "public"
    }

    private_a = {
      cidr_block = "10.20.11.0/24"
      az_key     = "a"
      tier       = "private"
    }

    private_b = {
      cidr_block = "10.20.12.0/24"
      az_key     = "b"
      tier       = "private"
    }
  }
}

locals {
  application_bucket_name = (
    "${var.project}-${var.environment}-artifacts-${var.application_bucket_suffix}"
  )
}
