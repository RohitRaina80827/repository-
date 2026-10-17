resource "aws_cloudwatch_log_group" "bootstrap" {
  name              = "/terraform-status-lab/prod-lab/bootstrap"
  retention_in_days = 7

  tags = {
    Project     = "terraform-status-lab"
    Environment = "prod-lab"
    ManagedBy   = "terraform"
  }
}

resource "aws_cloudwatch_log_group" "service" {
  name              = "/terraform-status-lab/prod-lab/service"
  retention_in_days = 7

  tags = {
    Project     = "terraform-status-lab"
    Environment = "prod-lab"
    ManagedBy   = "terraform"
  }
}

resource "aws_sns_topic" "monitoring_alerts" {
  name = "terraform-status-lab-prod-monitoring-alerts"

  tags = {
    Project     = "terraform-status-lab"
    Environment = "prod-lab"
    ManagedBy   = "terraform"
  }
}

resource "aws_sns_topic_subscription" "monitoring_email" {
  topic_arn = aws_sns_topic.monitoring_alerts.arn
  protocol  = "email"
  endpoint  = "amazoncloud80827@gmail.com"
}

data "aws_instances" "prod_app" {
  instance_state_names = ["running"]

  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.app.name]
  }
}

resource "aws_cloudwatch_metric_alarm" "prod_asg_capacity" {
  alarm_name          = "terraform-status-lab-prod-asg-capacity-low"
  alarm_description   = "Production ASG has fewer than two in-service instances."
  namespace           = "AWS/AutoScaling"
  metric_name         = "GroupInServiceInstances"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
  statistic           = "Minimum"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 2
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.monitoring_alerts.arn]
  ok_actions          = [aws_sns_topic.monitoring_alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "prod_service_unhealthy" {
  alarm_name          = "terraform-status-lab-prod-service-unhealthy"
  alarm_description   = "The production status service reports unhealthy."
  namespace           = "terraform-status-lab/prod-lab"
  metric_name         = "ServiceHealthy"
  statistic           = "Minimum"
  period              = 120
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  alarm_actions       = [aws_sns_topic.monitoring_alerts.arn]
  ok_actions          = [aws_sns_topic.monitoring_alerts.arn]

  tags = {
    Project     = "terraform-status-lab"
    Environment = "prod-lab"
    ManagedBy   = "terraform"
  }
}
