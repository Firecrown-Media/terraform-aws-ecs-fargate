# Auto Scaling Configuration for ECS Service
# Implements AWS best practices for elastic scaling

# Application Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.create_ecs_service && var.enable_auto_scaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${split("/", aws_ecs_service.main[0].cluster)[1]}/${aws_ecs_service.main[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-autoscaling-target"
    Type = "autoscaling-target"
  })
}

# Auto Scaling Policy - CPU Utilization
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  count              = var.create_ecs_service && var.enable_auto_scaling ? 1 : 0
  name               = "${local.name_prefix}-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.cpu_target_value
    scale_in_cooldown  = var.scale_down_cooldown
    scale_out_cooldown = var.scale_up_cooldown

    disable_scale_in = false
  }
}

# Auto Scaling Policy - Memory Utilization
resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  count              = var.create_ecs_service && var.enable_auto_scaling ? 1 : 0
  name               = "${local.name_prefix}-memory-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.memory_target_value
    scale_in_cooldown  = var.scale_down_cooldown
    scale_out_cooldown = var.scale_up_cooldown

    disable_scale_in = false
  }
}