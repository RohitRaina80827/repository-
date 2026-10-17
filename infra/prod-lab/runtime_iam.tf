resource "aws_iam_role" "runtime" {
  name = "terraform-status-lab-prod-runtime"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project     = "terraform-status-lab"
    Environment = "prod-lab"
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_instance_profile" "runtime" {
  name = "terraform-status-lab-prod-runtime-profile"
  role = aws_iam_role.runtime.name
}

resource "aws_iam_role_policy_attachment" "runtime_ssm" {
  role       = aws_iam_role.runtime.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "runtime_health_metric" {
  name = "publish-service-health-metric"
  role = aws_iam_role.runtime.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["cloudwatch:PutMetricData"]
      Resource = "*"
      Condition = {
        StringEquals = {
          "cloudwatch:namespace" = "terraform-status-lab/prod-lab"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "runtime_logs" {
  name = "terraform-status-lab-prod-logs"
  role = aws_iam_role.runtime.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ]
      Resource = [
        "${aws_cloudwatch_log_group.bootstrap.arn}:*",
        "${aws_cloudwatch_log_group.service.arn}:*"
      ]
    }]
  })
}
