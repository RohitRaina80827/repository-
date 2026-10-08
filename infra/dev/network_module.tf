module "network" {
  source = "./modules/network"

  availability_zones = var.availability_zones
  owner              = var.owner
}

