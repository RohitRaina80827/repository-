provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]

  default_tags {
    tags = {
      Project   = "terraform-infrastructure-lab"
      Purpose   = "remote-state"
      ManagedBy = "terraform"
    }
  }
}
