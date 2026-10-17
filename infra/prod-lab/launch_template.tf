resource "aws_launch_template" "app" {
  name_prefix   = "terraform-status-lab-prod-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.runtime.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(templatefile(
    "${path.root}/../../scripts/bootstrap-status-prod.sh",
    {
      project_name = "terraform-status-lab"
      release_id   = var.release_id
      bucket_name  = ""
      artifact_key = ""
      cloudwatch_agent_config = jsonencode({
        logs = {
          logs_collected = {
            files = {
              collect_list = [
                {
                  file_path       = "/var/log/status-bootstrap.log"
                  log_group_name  = "/terraform-status-lab/prod-lab/bootstrap"
                  log_stream_name = "{instance_id}"
                }
                ,
                {
                  file_path       = "/var/log/nginx/access.log"
                  log_group_name  = "/terraform-status-lab/prod-lab/service"
                  log_stream_name = "{instance_id}-access"
                },
                {
                  file_path       = "/var/log/nginx/error.log"
                  log_group_name  = "/terraform-status-lab/prod-lab/service"
                  log_stream_name = "{instance_id}-error"
                }
              ]
            }
          }
        }
      })
    }
  ))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "terraform-status-lab-prod-app"
      Project     = "terraform-status-lab"
      Environment = "prod-lab"
      Owner       = var.owner
      ManagedBy   = "terraform"
      Release     = var.release_id
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Project     = "terraform-status-lab"
      Environment = "prod-lab"
      Owner       = var.owner
      ManagedBy   = "terraform"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
