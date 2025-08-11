# SNS Topic for Alarms (optional)
resource "aws_sns_topic" "alarms" {
  count = var.enable_monitoring && var.enable_sns_notifications && var.sns_topic_arn == "" ? 1 : 0
  name  = "${var.name}-alarms"
  tags  = local.common_tags
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  count          = var.enable_monitoring ? 1 : 0
  dashboard_name = "${var.name}-ecs-dashboard"

  dashboard_body = jsonencode({
    widgets = concat([
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", local.service_name, "ClusterName", aws_ecs_cluster.main.name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "ECS Service CPU and Memory Utilization"
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
          metrics = [
            ["AWS/ECS", "RunningTaskCount", "ServiceName", local.service_name, "ClusterName", aws_ecs_cluster.main.name],
            [".", "PendingTaskCount", ".", ".", ".", "."],
            [".", "DesiredCount", ".", ".", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "ECS Service Task Counts"
          period  = 300
        }
      }
    ],
    var.create_alb ? [
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main[0].arn_suffix],
            [".", "RequestCount", ".", "."],
            [".", "HTTPCode_Target_2XX_Count", ".", "."],
            [".", "HTTPCode_Target_4XX_Count", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "ALB Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", aws_lb_target_group.main[0].arn_suffix],
            [".", "UnHealthyHostCount", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Target Group Health"
          period  = 300
        }
      }
    ] : [])
  })

  depends_on = [aws_ecs_service.main]
}

# CloudWatch Alarm - High CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.enable_monitoring && var.create_service ? 1 : 0
  alarm_name          = "${var.name}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors ECS service CPU utilization"
  alarm_actions       = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  tags                = local.common_tags

  dimensions = {
    ServiceName = aws_ecs_service.main[0].name
    ClusterName = aws_ecs_cluster.main.name
  }

  depends_on = [aws_ecs_service.main]
}

# CloudWatch Alarm - High Memory Utilization
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.enable_monitoring && var.create_service ? 1 : 0
  alarm_name          = "${var.name}-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_description   = "This metric monitors ECS service memory utilization"
  alarm_actions       = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  tags                = local.common_tags

  dimensions = {
    ServiceName = aws_ecs_service.main[0].name
    ClusterName = aws_ecs_cluster.main.name
  }

  depends_on = [aws_ecs_service.main]
}

# CloudWatch Alarm - Service Task Count
resource "aws_cloudwatch_metric_alarm" "task_count" {
  count               = var.enable_monitoring && var.create_service ? 1 : 0
  alarm_name          = "${var.name}-running-task-count-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.desired_count
  alarm_description   = "This metric monitors ECS service running task count"
  alarm_actions       = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  tags                = local.common_tags

  dimensions = {
    ServiceName = aws_ecs_service.main[0].name
    ClusterName = aws_ecs_cluster.main.name
  }

  depends_on = [aws_ecs_service.main]
}

# CloudWatch Alarm - ALB Target Response Time
resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  count               = var.enable_monitoring && var.create_alb ? 1 : 0
  alarm_name          = "${var.name}-alb-response-time-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = 1.0
  alarm_description   = "This metric monitors ALB target response time"
  alarm_actions       = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  tags                = local.common_tags

  dimensions = {
    LoadBalancer = aws_lb.main[0].arn_suffix
  }

  depends_on = [aws_lb.main]
}

# CloudWatch Alarm - ALB 5xx Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  count               = var.enable_monitoring && var.create_alb ? 1 : 0
  alarm_name          = "${var.name}-alb-5xx-errors-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "This metric monitors ALB 5xx error count"
  alarm_actions       = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  tags                = local.common_tags

  dimensions = {
    LoadBalancer = aws_lb.main[0].arn_suffix
  }

  depends_on = [aws_lb.main]
}

# CloudWatch Alarm - Unhealthy Host Count
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  count               = var.enable_monitoring && var.create_alb ? 1 : 0
  alarm_name          = "${var.name}-unhealthy-hosts-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "This metric monitors unhealthy host count"
  alarm_actions       = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.alarms[0].arn] : []
  tags                = local.common_tags

  dimensions = {
    TargetGroup = aws_lb_target_group.main[0].arn_suffix
  }

  depends_on = [aws_lb_target_group.main]
}

# CloudWatch Log Insights Queries (as outputs for easy access)
locals {
  log_insights_queries = var.enable_monitoring ? {
    error_logs = {
      query_string = "fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 100"
      log_group    = aws_cloudwatch_log_group.main.name
    }

    slow_requests = {
      query_string = "fields @timestamp, @message, @duration | filter @type = \"REPORT\" | filter @duration > 1000 | sort @duration desc | limit 100"
      log_group    = aws_cloudwatch_log_group.main.name
    }

    memory_usage = {
      query_string = "fields @timestamp, @message, @maxMemoryUsed, @memorySize | filter @type = \"REPORT\" | stats avg(@maxMemoryUsed), max(@maxMemoryUsed), min(@maxMemoryUsed) by bin(5m)"
      log_group    = aws_cloudwatch_log_group.main.name
    }
  } : {}
}