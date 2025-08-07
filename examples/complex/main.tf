# Complex ECS Example with EC2, Spot Instances, and Full Observability
# This example demonstrates advanced features including EC2 launch type,
# mixed instances policy, Blue/Green deployments, and comprehensive monitoring

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Data sources for existing VPC and subnets
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    Type = "private"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    Type = "public"
  }
}

# SNS Topic for notifications
resource "aws_sns_topic" "notifications" {
  name = "${var.name}-notifications"
  tags = var.tags
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "email" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Complex ECS deployment with all features enabled
module "ecs_complex" {
  source = "../../"

  # Basic Configuration
  name            = var.name
  environment     = var.environment
  vpc_id          = data.aws_vpc.main.id
  private_subnets = data.aws_subnets.private.ids
  public_subnets  = data.aws_subnets.public.ids

  # ECS Configuration
  launch_type               = "EC2"
  enable_container_insights = true

  # Container Configuration
  container_image = var.container_image
  container_port  = var.container_port
  task_cpu        = var.task_cpu
  task_memory     = var.task_memory

  # Environment variables and secrets
  container_environment = var.container_environment
  container_secrets     = var.container_secrets

  # Service Configuration
  desired_count                      = var.desired_count
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  enable_circuit_breaker             = true
  enable_rollback                    = true

  # EC2 Configuration
  instance_type          = var.instance_type
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity
  mixed_instances_policy = true
  on_demand_percentage   = var.on_demand_percentage
  spot_instance_types    = var.spot_instance_types

  # Load Balancer Configuration
  create_alb                 = true
  alb_internal               = false
  enable_deletion_protection = var.enable_deletion_protection
  health_check_path          = var.health_check_path
  health_check_interval      = 15
  health_check_timeout       = 5
  healthy_threshold          = 2
  unhealthy_threshold        = 3
  certificate_arn            = var.certificate_arn
  ssl_policy                 = "ELBSecurityPolicy-TLS-1-2-2017-01"

  # Auto Scaling Configuration
  enable_autoscaling  = true
  min_capacity        = var.autoscaling_min_capacity
  max_capacity        = var.autoscaling_max_capacity
  target_cpu          = var.target_cpu_utilization
  target_memory       = var.target_memory_utilization
  scale_up_cooldown   = 300
  scale_down_cooldown = 300

  # Monitoring Configuration
  enable_monitoring        = true
  cpu_alarm_threshold      = 80
  memory_alarm_threshold   = 80
  enable_sns_notifications = true
  sns_topic_arn            = aws_sns_topic.notifications.arn

  # CodeDeploy Configuration (Blue/Green)
  enable_code_deploy               = var.enable_code_deploy
  termination_wait_time_in_minutes = 5

  # Logging Configuration
  log_retention_days = var.log_retention_days

  tags = var.tags
}

# Additional CloudWatch Alarms for advanced monitoring
resource "aws_cloudwatch_metric_alarm" "disk_utilization" {
  alarm_name          = "${var.name}-disk-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 instance disk utilization"
  alarm_actions       = [aws_sns_topic.notifications.arn]
  tags                = var.tags

  dimensions = {
    AutoScalingGroupName = module.ecs_complex.autoscaling_group_name
  }
}

# CloudWatch Event Rule for ECS Task State Changes
resource "aws_cloudwatch_event_rule" "ecs_task_state_change" {
  name        = "${var.name}-ecs-task-state-change"
  description = "Capture ECS task state changes"
  tags        = var.tags

  event_pattern = jsonencode({
    source      = ["aws.ecs"]
    detail-type = ["ECS Task State Change"]
    detail = {
      clusterArn = [module.ecs_complex.cluster_arn]
    }
  })
}

# CloudWatch Event Target for SNS
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.ecs_task_state_change.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.notifications.arn
}