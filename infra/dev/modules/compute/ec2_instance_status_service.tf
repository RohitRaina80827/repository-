
resource "aws_instance" "status" {
  count         = var.enable_compute ? 1 : 0
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.public_subnet_id

  associate_public_ip_address = true

  iam_instance_profile = var.instance_profile_name

  vpc_security_group_ids = [
    var.security_group_id
  ]
  user_data = templatefile(
    "${path.root}/../../scripts/bootstrap-status.sh",
    {
      project_name = "terraform-status-lab"
      release_id   = var.release_id
      bucket_name  = var.bucket_name
      artifact_key = var.artifact_key
    }
  )

  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"

    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

output "security_details" {
  value = var.enable_compute ? {
    imds_http_tokens = aws_instance.status[0].metadata_options[0].http_tokens

    root_volume_encrypted = aws_instance.status[0].root_block_device[0].encrypted
  } : null
}

