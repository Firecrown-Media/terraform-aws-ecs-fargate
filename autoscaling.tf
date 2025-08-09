# Data source for latest ECS optimized AMI
data "aws_ssm_parameter" "ecs_optimized_ami" {
  count = var.launch_type == "EC2" ? 1 : 0
  name  = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Launch Template for EC2 instances
resource "aws_launch_template" "ecs" {
  count       = var.launch_type == "EC2" ? 1 : 0
  name        = "${var.name}-ecs-launch-template"
  description = "Launch template for ECS cluster EC2 instances"
  tags        = local.common_tags

  image_id      = data.aws_ssm_parameter.ecs_optimized_ami[0].value
  instance_type = var.instance_type
  key_name      = var.spot_price != "" ? null : var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2_instances[0].id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs[0].name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = aws_ecs_cluster.main.name
  }))

  dynamic "instance_market_options" {
    for_each = var.spot_price != "" ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price = var.spot_price
      }
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      name = "${var.name}-ecs-instance"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group for EC2 instances
resource "aws_autoscaling_group" "ecs" {
  count                     = var.launch_type == "EC2" ? 1 : 0
  name                      = "${var.name}-ecs-asg"
  vpc_zone_identifier       = var.private_subnets
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "EC2"
  health_check_grace_period = 300

  # Use mixed instances policy for cost optimization
  dynamic "mixed_instances_policy" {
    for_each = var.mixed_instances_policy ? [1] : []
    content {
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.ecs[0].id
          version            = "$Latest"
        }

        dynamic "override" {
          for_each = var.spot_instance_types
          content {
            instance_type = override.value
          }
        }
      }

      instances_distribution {
        on_demand_base_capacity                  = var.on_demand_percentage >= 100 ? length(var.availability_zones) : 0
        on_demand_percentage_above_base_capacity = var.on_demand_percentage >= 100 ? 100 : var.on_demand_percentage
        on_demand_allocation_strategy            = "prioritized"
        spot_allocation_strategy                 = "diversified"
        spot_instance_pools                      = 2
      }
    }
  }

  # Use launch template directly if not using mixed instances policy
  dynamic "launch_template" {
    for_each = var.mixed_instances_policy ? [] : [1]
    content {
      id      = aws_launch_template.ecs[0].id
      version = "$Latest"
    }
  }

  # Auto Scaling policies will be managed by ECS capacity provider
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "name"
    value               = "${var.name}-ecs-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# Auto Scaling Target for ECS Service
resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.create_service && var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags               = local.common_tags

  depends_on = [aws_ecs_service.main]
}

# Auto Scaling Policy for CPU utilization
resource "aws_appautoscaling_policy" "cpu" {
  count              = var.create_service && var.enable_autoscaling ? 1 : 0
  name               = "${var.name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.target_cpu
    scale_in_cooldown  = var.scale_down_cooldown
    scale_out_cooldown = var.scale_up_cooldown
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

# Auto Scaling Policy for Memory utilization
resource "aws_appautoscaling_policy" "memory" {
  count              = var.create_service && var.enable_autoscaling ? 1 : 0
  name               = "${var.name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.target_memory
    scale_in_cooldown  = var.scale_down_cooldown
    scale_out_cooldown = var.scale_up_cooldown
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

# Auto Scaling Policy for ALB Request Count (if ALB is enabled)
resource "aws_appautoscaling_policy" "alb_request_count" {
  count              = var.create_service && var.enable_autoscaling && var.create_alb ? 1 : 0
  name               = "${var.name}-alb-request-count-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.main[0].arn_suffix}/${aws_lb_target_group.main[0].arn_suffix}"
    }

    target_value       = 1000
    scale_in_cooldown  = var.scale_down_cooldown
    scale_out_cooldown = var.scale_up_cooldown
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}