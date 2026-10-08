output "stage6_backend_check" {
  value = "dev state is separate from bootstrap"
}

output "application_bucket_name" {
  value = module.storage.bucket_name
}

output "application_bucket_arn" {
  value = module.storage.bucket_arn
}
output "status_instance_id" {
  value = var.enable_compute ? module.compute.status_instance_id : null
}

