resource "aws_security_group" "alb" {
  name        = "terraform-status-lab-prod-alb"
  description = "Public HTTP ingress to the production load balancer"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "HTTP ingress for initial connectivity testing"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Forward traffic and health checks to application targets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terraform-status-lab-prod-alb"
    Project     = "terraform-status-lab"
    Environment = "prod-lab"
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "app" {
  name        = "terraform-status-lab-prod-app"
  description = "Allow application traffic only from the ALB"
  vpc_id      = module.network.vpc_id

  ingress {
    description     = "Application and health-check traffic from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Outbound access for bootstrap, SSM, and monitoring"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terraform-status-lab-prod-app"
    Project     = "terraform-status-lab"
    Environment = "prod-lab"
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

resource "aws_lb" "app" {
  name               = "terraform-status-lab-prod"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = values(module.network.public_subnet_ids)

  enable_deletion_protection = false

  tags = {
    Name        = "terraform-status-lab-prod"
    Project     = "terraform-status-lab"
    Environment = "prod-lab"
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

resource "aws_lb_target_group" "app" {
  name        = "terraform-status-prod-app"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.network.vpc_id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Project     = "terraform-status-lab"
    Environment = "prod-lab"
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

# Temporary HTTP listener for initial testing.
# Replace with HTTPS and an HTTP-to-HTTPS redirect after ACM validation.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
