resource "aws_autoscaling_group" "app" {
  name                = "terraform-status-lab-prod-asg"
  min_size            = 2
  desired_capacity    = 2
  max_size            = 4
  vpc_zone_identifier = values(module.network.private_subnet_ids)

  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 600
  default_instance_warmup   = 600

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 100
      max_healthy_percentage = 150
      instance_warmup        = 600
      skip_matching          = true
    }
  }

  tag {
    key                 = "Name"
    value               = "terraform-status-lab-prod-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "terraform-status-lab"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "prod-lab"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = var.owner
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "terraform"
    propagate_at_launch = true
  }
}
