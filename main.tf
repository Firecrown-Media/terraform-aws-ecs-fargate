locals {
  cluster_name   = var.cluster_name != "" ? var.cluster_name : var.name
  service_name   = var.service_name != "" ? var.service_name : var.name
  alb_name       = var.alb_name != "" ? var.alb_name : var.name
  log_group_name = var.log_group_name != "" ? var.log_group_name : "/aws/ecs/${var.name}"

  common_tags = merge(var.tags, {
    Name        = var.name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = local.log_group_name
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = local.cluster_name
  tags = local.common_tags

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  dynamic "configuration" {
    for_each = var.launch_type == "EC2" ? [1] : []
    content {
      execute_command_configuration {
        logging = "OVERRIDE"
        log_configuration {
          cloud_watch_log_group_name = aws_cloudwatch_log_group.main.name
        }
      }
    }
  }
}

# ECS Cluster Capacity Providers (for EC2 launch type)
resource "aws_ecs_cluster_capacity_providers" "main" {
  count        = var.launch_type == "EC2" ? 1 : 0
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = var.mixed_instances_policy ? ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.main[0].name] : ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = var.mixed_instances_policy ? aws_ecs_capacity_provider.main[0].name : "FARGATE"
    weight            = 1
  }
}

# ECS Capacity Provider (for EC2 launch type)
resource "aws_ecs_capacity_provider" "main" {
  count = var.launch_type == "EC2" ? 1 : 0
  name  = "${local.cluster_name}-capacity-provider"
  tags  = local.common_tags

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs[0].arn

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }

    managed_termination_protection = "ENABLED"
  }
}

# Default Task Definition (when not provided)
resource "aws_ecs_task_definition" "main" {
  count                    = var.task_definition_arn == "" && var.create_service ? 1 : 0
  family                   = local.service_name
  network_mode             = var.launch_type == "FARGATE" ? "awsvpc" : "bridge"
  requires_compatibilities = [var.launch_type]
  cpu                      = var.launch_type == "FARGATE" ? var.task_cpu : null
  memory                   = var.launch_type == "FARGATE" ? var.task_memory : null
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  tags                     = local.common_tags

  # EFS Volumes
  dynamic "volume" {
    for_each = local.efs_volumes
    content {
      name = volume.value.name

      efs_volume_configuration {
        file_system_id          = volume.value.efs_volume_configuration.file_system_id
        root_directory          = volume.value.efs_volume_configuration.root_directory
        transit_encryption      = volume.value.efs_volume_configuration.transit_encryption
        transit_encryption_port = volume.value.efs_volume_configuration.transit_encryption_port

        dynamic "authorization_config" {
          for_each = volume.value.efs_volume_configuration.authorization_config != null ? [volume.value.efs_volume_configuration.authorization_config] : []
          content {
            access_point_id = authorization_config.value.access_point_id
            iam             = authorization_config.value.iam
          }
        }
      }
    }
  }

  container_definitions = jsonencode([
    merge({
      name  = local.service_name
      image = var.container_image

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
          hostPort      = var.launch_type == "FARGATE" ? var.container_port : 0
        }
      ]

      environment = var.container_environment
      secrets     = var.container_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }

      essential = true

      memory = var.launch_type == "EC2" ? var.task_memory : null

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }, length(local.efs_mount_points) > 0 ? {
      mountPoints = local.efs_mount_points
    } : {})
  ])
}

# ECS Service
resource "aws_ecs_service" "main" {
  count            = var.create_service ? 1 : 0
  name             = local.service_name
  cluster          = aws_ecs_cluster.main.id
  task_definition  = var.task_definition_arn != "" ? var.task_definition_arn : aws_ecs_task_definition.main[0].arn
  desired_count    = var.desired_count
  launch_type      = var.launch_type
  platform_version = var.launch_type == "FARGATE" ? "LATEST" : null
  tags             = local.common_tags

  dynamic "capacity_provider_strategy" {
    for_each = var.launch_type == "EC2" && var.mixed_instances_policy ? [1] : []
    content {
      capacity_provider = aws_ecs_capacity_provider.main[0].name
      weight            = 1
      base              = 0
    }
  }

  dynamic "network_configuration" {
    for_each = var.launch_type == "FARGATE" ? [1] : []
    content {
      subnets          = var.private_subnets
      security_groups  = [aws_security_group.ecs_tasks.id]
      assign_public_ip = false
    }
  }

  dynamic "load_balancer" {
    for_each = var.create_alb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.main[0].arn
      container_name   = local.service_name
      container_port   = var.container_port
    }
  }

  deployment_configuration {
    maximum_percent         = var.deployment_maximum_percent
    minimum_healthy_percent = var.deployment_minimum_healthy_percent

    dynamic "deployment_circuit_breaker" {
      for_each = var.enable_circuit_breaker ? [1] : []
      content {
        enable   = true
        rollback = var.enable_rollback
      }
    }
  }

  depends_on = [
    aws_lb_listener.main,
    aws_iam_role_policy_attachment.ecs_execution_role_policy,
    aws_iam_role_policy_attachment.ecs_task_role_policy
  ]

  lifecycle {
    ignore_changes = [task_definition]
  }
}

# CodeDeploy Application
resource "aws_codedeploy_app" "main" {
  count            = var.enable_code_deploy && var.create_service ? 1 : 0
  compute_platform = "ECS"
  name             = "${local.service_name}-codedeploy"
  tags             = local.common_tags
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "main" {
  count                  = var.enable_code_deploy && var.create_service ? 1 : 0
  app_name               = aws_codedeploy_app.main[0].name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "${local.service_name}-deployment-group"
  service_role_arn       = aws_iam_role.codedeploy_service_role[0].arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.main[0].name
  }

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.main[0].name
    }
  }

  tags = local.common_tags
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}