# CloudWatch Monitoring and Alarms
# Implements comprehensive monitoring following AWS best practices

# CloudWatch Alarms for ECS Service
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  count               = var.create_ecs_service && var.enable_monitoring ? 1 : 0
  alarm_name          = "${local.name_prefix}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS service CPU utilization"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    ServiceName = aws_ecs_service.main[0].name
    ClusterName = split("/", aws_ecs_service.main[0].cluster)[1]
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-ecs-cpu-high"
    Type      = "cloudwatch-alarm"
    Severity  = "warning"
    Component = "ecs-service"
  })
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  count               = var.create_ecs_service && var.enable_monitoring ? 1 : 0
  alarm_name          = "${local.name_prefix}-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ECS service memory utilization"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    ServiceName = aws_ecs_service.main[0].name
    ClusterName = split("/", aws_ecs_service.main[0].cluster)[1]
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-ecs-memory-high"
    Type      = "cloudwatch-alarm"
    Severity  = "warning"
    Component = "ecs-service"
  })
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_count" {
  count               = var.create_ecs_service && var.enable_monitoring ? 1 : 0
  alarm_name          = "${local.name_prefix}-ecs-service-count-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.min_capacity
  alarm_description   = "This metric monitors ECS service running task count"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions
  treat_missing_data  = "breaching"

  dimensions = {
    ServiceName = aws_ecs_service.main[0].name
    ClusterName = split("/", aws_ecs_service.main[0].cluster)[1]
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-ecs-service-count-low"
    Type      = "cloudwatch-alarm"
    Severity  = "critical"
    Component = "ecs-service"
  })
}

# ALB Target Group Health Alarms
resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  count               = local.create_alb_resources && var.create_ecs_service && var.enable_monitoring ? 1 : 0
  alarm_name          = "${local.name_prefix}-alb-response-time-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "This metric monitors ALB target response time"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    LoadBalancer = aws_lb.main[0].arn_suffix
    TargetGroup  = aws_lb_target_group.main[0].arn_suffix
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-alb-response-time-high"
    Type      = "cloudwatch-alarm"
    Severity  = "warning"
    Component = "alb"
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_healthy_host_count" {
  count               = local.create_alb_resources && var.create_ecs_service && var.enable_monitoring ? 1 : 0
  alarm_name          = "${local.name_prefix}-alb-healthy-hosts-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ALB healthy host count"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions
  treat_missing_data  = "breaching"

  dimensions = {
    LoadBalancer = aws_lb.main[0].arn_suffix
    TargetGroup  = aws_lb_target_group.main[0].arn_suffix
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-alb-healthy-hosts-low"
    Type      = "cloudwatch-alarm"
    Severity  = "critical"
    Component = "alb"
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_http_5xx_count" {
  count               = local.create_alb_resources && var.create_ecs_service && var.enable_monitoring ? 1 : 0
  alarm_name          = "${local.name_prefix}-alb-5xx-errors-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors ALB 5XX error count"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main[0].arn_suffix
    TargetGroup  = aws_lb_target_group.main[0].arn_suffix
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-alb-5xx-errors-high"
    Type      = "cloudwatch-alarm"
    Severity  = "warning"
    Component = "alb"
  })
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  count          = var.create_ecs_service && var.enable_monitoring && var.create_dashboard ? 1 : 0
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.main[0].name, "ClusterName", split("/", aws_ecs_service.main[0].cluster)[1]],
            [".", "MemoryUtilization", ".", ".", ".", "."],
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.id
          title   = "ECS Service Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = concat(
            local.create_alb_resources ? [
              ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main[0].arn_suffix, "TargetGroup", aws_lb_target_group.main[0].arn_suffix],
              [".", "HealthyHostCount", ".", ".", ".", "."],
              [".", "RequestCount", ".", ".", ".", "."],
            ] : [],
            []
          )
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.id
          title   = "ALB Metrics"
          period  = 300
        }
      }
    ]
  })
}

# Monitoring variables are now defined in variables.tf