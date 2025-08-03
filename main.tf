# terraform-aws-ecs-fargate Module
# A comprehensive ECS Fargate module with ALB, Auto Scaling, and Spot Instance support
# Follows AWS and Terraform best practices for production workloads

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.0"
    }
  }
}

# Local values for consistent resource naming and tagging
locals {
  # Ensure name doesn't exceed AWS naming limits
  name_prefix = substr(var.name, 0, 32)

  # Standard tags applied to all resources
  common_tags = merge(
    var.tags,
    {
      Module      = "terraform-aws-ecs-fargate"
      Component   = var.component
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  # Conditional resource creation flags
  create_alb_resources = var.create_alb && var.alb_enabled
  create_ecs_resources = var.create_ecs_cluster || var.create_ecs_service
  create_monitoring    = var.enable_monitoring

  # Security and networking
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Container configuration
  container_definitions = var.custom_container_definitions != null ? var.custom_container_definitions : [
    {
      name      = "${local.name_prefix}-app"
      image     = var.container_image
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
          name          = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main[0].name
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = var.container_environment
      secrets     = var.container_secrets

      healthCheck = var.container_health_check != null ? var.container_health_check : {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ]
}