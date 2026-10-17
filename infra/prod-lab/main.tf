module "network" {
  source = "./modules/network"

  availability_zones = var.availability_zones
  owner              = var.owner
  network_name       = "terraform-status-lab-prod"
  project            = "terraform-status-lab"
  environment        = "prod-lab"
  vpc_cidr           = "10.30.0.0/16"
}
