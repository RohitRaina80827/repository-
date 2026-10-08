module "compute" {
  source = "./modules/compute"

  enable_compute = var.enable_compute

  ami_id        = var.ami_id
  instance_type = var.instance_type
  release_id    = var.release_id

  public_subnet_id = module.network.public_subnet_ids["public_a"]

  instance_profile_name = aws_iam_instance_profile.runtime.name
  security_group_id     = aws_security_group.core.id
  bucket_name           = module.storage.bucket_name
  artifact_key          = module.storage.artifact_key
}

