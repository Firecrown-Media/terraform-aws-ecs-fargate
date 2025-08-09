# Simple Fargate ECS Example
# This example demonstrates a basic Fargate deployment with minimal configuration

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
    name   = "tag:name"
    values = ["main-vpc"] # Adjust this to match your VPC name
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    type = "private" # Adjust this to match your subnet tags
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  tags = {
    type = "public" # Adjust this to match your subnet tags
  }
}

# Simple ECS Fargate deployment
module "ecs_fargate" {
  source = "../../"

  # Basic Configuration
  name            = var.name
  environment     = var.environment
  vpc_id          = data.aws_vpc.main.id
  private_subnets = data.aws_subnets.private.ids
  public_subnets  = data.aws_subnets.public.ids

  # Container Configuration
  container_image = var.container_image
  container_port  = var.container_port
  task_cpu        = var.task_cpu
  task_memory     = var.task_memory

  # Service Configuration
  desired_count = var.desired_count

  # Load Balancer
  create_alb        = true
  health_check_path = var.health_check_path
  certificate_arn   = var.certificate_arn

  # Auto Scaling
  enable_autoscaling = true
  min_capacity       = 1
  max_capacity       = 10
  target_cpu         = 70

  # Monitoring
  enable_monitoring = true

  tags = var.tags
}

# Output the application URL
output "application_url" {
  description = "URL to access the application"
  value       = module.ecs_fargate.application_url
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_fargate.cluster_name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_fargate.service_name
}