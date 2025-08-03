# ECS Cluster, Task Definition, and Service Configuration
# Core container orchestration resources

# Data sources for region and availability zones
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_caller_identity" "current" {}

# CloudWatch Log Group for ECS Tasks
resource "aws_cloudwatch_log_group" "main" {
  count             = var.create_ecs_service ? 1 : 0
  name              = "/aws/ecs/${local.name_prefix}"
  retention_in_days = var.log_retention_in_days

  tags = local.common_tags
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  count = var.create_ecs_cluster ? 1 : 0
  name  = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.main[0].name
      }
    }
  }

  tags = local.common_tags
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  count                    = var.create_ecs_service ? 1 : 0
  family                   = var.task_definition_family != "" ? var.task_definition_family : local.name_prefix
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution[0].arn
  task_role_arn            = var.create_task_role ? aws_iam_role.ecs_task[0].arn : null

  container_definitions = jsonencode(local.container_definitions)

  dynamic "runtime_platform" {
    for_each = var.runtime_platform != null ? [var.runtime_platform] : []
    content {
      operating_system_family = runtime_platform.value.operating_system_family
      cpu_architecture        = runtime_platform.value.cpu_architecture
    }
  }

  dynamic "volume" {
    for_each = var.efs_volumes
    content {
      name = volume.value.name

      efs_volume_configuration {
        file_system_id          = volume.value.file_system_id
        root_directory          = volume.value.root_directory
        transit_encryption      = volume.value.transit_encryption
        transit_encryption_port = volume.value.transit_encryption_port

        dynamic "authorization_config" {
          for_each = volume.value.authorization_config != null ? [volume.value.authorization_config] : []
          content {
            access_point_id = authorization_config.value.access_point_id
            iam             = authorization_config.value.iam
          }
        }
      }
    }
  }

  tags = local.common_tags
}

# ECS Service with Spot Instance Support
resource "aws_ecs_service" "main" {
  count           = var.create_ecs_service ? 1 : 0
  name            = "${local.name_prefix}-service"
  cluster         = var.ecs_cluster_arn != "" ? var.ecs_cluster_arn : aws_ecs_cluster.main[0].id
  task_definition = aws_ecs_task_definition.main[0].arn
  desired_count   = var.desired_count

  # Capacity provider strategy for spot/on-demand mix
  dynamic "capacity_provider_strategy" {
    for_each = var.enable_spot_instances ? [1] : []
    content {
      capacity_provider = "FARGATE_SPOT"
      weight            = var.spot_instance_weight
      base              = var.spot_instance_base
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.enable_spot_instances ? [1] : []
    content {
      capacity_provider = "FARGATE"
      weight            = var.on_demand_weight
      base              = var.on_demand_base
    }
  }

  # Fallback to launch_type when not using capacity providers
  launch_type = var.enable_spot_instances ? null : "FARGATE"

  platform_version                  = var.platform_version
  health_check_grace_period_seconds = var.health_check_grace_period

  network_configuration {
    security_groups  = concat([aws_security_group.ecs_tasks[0].id], var.additional_security_groups)
    subnets          = local.private_subnets
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.create_alb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.main[0].arn
      container_name   = "${local.name_prefix}-app"
      container_port   = var.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.enable_service_discovery ? [1] : []
    content {
      registry_arn = aws_service_discovery_service.main[0].arn
    }
  }

  # Basic deployment configuration (advanced settings can be added separately)
  # deployment_configuration block syntax varies by provider version

  enable_execute_command = var.enable_execute_command

  # Ensure capacity providers are available in cluster
  depends_on = [
    aws_lb_listener.https,
    aws_iam_role_policy_attachment.ecs_task_execution,
    aws_ecs_cluster_capacity_providers.main
  ]

  tags = local.common_tags

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# ECS Cluster Capacity Providers for Spot/On-Demand support
resource "aws_ecs_cluster_capacity_providers" "main" {
  count        = var.create_ecs_cluster && var.enable_spot_instances ? 1 : 0
  cluster_name = aws_ecs_cluster.main[0].name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = var.default_capacity_provider_base
    weight            = var.default_capacity_provider_weight
    capacity_provider = var.default_capacity_provider
  }
}