module "storage" {
  source = "./modules/storage"

  bucket_name = local.application_bucket_name
  tags        = local.network_tags
}

