output "status_instance_id" {
  value = var.enable_compute ? aws_instance.status[0].id : null
}

