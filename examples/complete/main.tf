# Complete Example: ECS Fargate with Spot Instances, EFS, SSL, and DNS
# This example demonstrates all features extracted from root modules

# Data sources for existing infrastructure
data "aws_vpc" "main" {
  tags = {
    Name = "main-vpc"
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

data "aws_route53_zone" "main" {
  name         = "example.com"
  private_zone = false
}

# Complete ECS Fargate deployment with all extracted features
module "ecs_fargate_app" {
  source = "../../"

  # Basic configuration
  name        = "my-app"
  environment = "prod"
  component   = "web-api"

  # Network configuration
  vpc_id          = data.aws_vpc.main.id
  private_subnets = data.aws_subnets.private.ids
  public_subnets  = data.aws_subnets.public.ids

  # Container configuration
  container_image = "nginx:latest"
  container_port  = 80
  task_cpu        = 512
  task_memory     = 1024
  desired_count   = 2

  # Spot instance configuration for cost optimization
  enable_spot_instances = true
  spot_instance_weight  = 70
  spot_instance_base    = 0
  on_demand_weight      = 30
  on_demand_base        = 1

  # Auto scaling configuration
  enable_auto_scaling = true
  min_capacity        = 1
  max_capacity        = 10
  cpu_target_value    = 70
  memory_target_value = 80

  # ALB configuration
  create_alb                     = true
  alb_enable_deletion_protection = true
  enable_alb_access_logs         = false
  ssl_policy                     = "ELBSecurityPolicy-TLS-1-2-2017-01"

  # SSL certificate configuration
  create_ssl_certificate        = true
  domain_name                   = "api.example.com"
  subject_alternative_names     = ["www.api.example.com"]
  certificate_validation_method = "DNS"
  route53_zone_id               = data.aws_route53_zone.main.zone_id

  # DNS configuration
  create_dns_record = true

  # Route53 health checks
  create_route53_health_check    = true
  health_check_type              = "HTTPS"
  health_check_resource_path     = "/health"
  health_check_failure_threshold = 3

  # EFS storage configuration
  enable_efs           = true
  efs_performance_mode = "generalPurpose"
  efs_throughput_mode  = "bursting"
  efs_encrypted        = true
  create_efs_kms_key   = true
  enable_efs_backup    = true
  efs_transition_to_ia = "AFTER_30_DAYS"

  # EFS access points for different application directories
  efs_access_points = {
    uploads = {
      root_directory_path = "/uploads"
      owner_gid           = 1000
      owner_uid           = 1000
      permissions         = "755"
      posix_gid           = 1000
      posix_uid           = 1000
      secondary_gids      = []
    }
    cache = {
      root_directory_path = "/cache"
      owner_gid           = 1000
      owner_uid           = 1000
      permissions         = "755"
      posix_gid           = 1000
      posix_uid           = 1000
      secondary_gids      = []
    }
  }

  # S3 storage configuration
  create_s3_bucket      = true
  s3_versioning_enabled = true
  s3_lifecycle_rules = [
    {
      id                                 = "cleanup_old_versions"
      status                             = "Enabled"
      expiration_days                    = null
      noncurrent_version_expiration_days = 90
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  # Target group health checks
  target_group_health_check_path     = "/health"
  target_group_health_check_interval = 30
  target_group_healthy_threshold     = 2
  target_group_unhealthy_threshold   = 3

  # Container environment variables
  container_environment = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "LOG_LEVEL"
      value = "info"
    }
  ]

  # Security configuration
  allowed_cidr_blocks = ["0.0.0.0/0"]

  # Monitoring and logging
  enable_monitoring     = true
  log_retention_in_days = 30

  # Deployment configuration
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  enable_deployment_circuit_breaker  = true
  enable_deployment_rollback         = true

  # Service discovery (optional)
  enable_service_discovery = false

  # Note: CI/CD is now handled via GitHub Actions
  # See .github/workflows/ for deployment automation

  # Tags
  tags = {
    Project    = "MyProject"
    Owner      = "DevOps Team"
    CostCenter = "Engineering"
    Backup     = "Required"
  }
}

# Outputs to demonstrate extracted resource access
output "application_url" {
  description = "URL to access the application"
  value       = module.ecs_fargate_app.application_url
}

output "custom_domain_url" {
  description = "Custom domain URL"
  value       = module.ecs_fargate_app.custom_domain_url
}

output "efs_file_system_id" {
  description = "EFS file system ID for mounting in containers"
  value       = module.ecs_fargate_app.efs_file_system_id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN for application data"
  value       = module.ecs_fargate_app.s3_bucket_arn
}

output "spot_instance_configuration" {
  description = "Spot instance configuration details"
  value       = module.ecs_fargate_app.capacity_provider_strategy
}

output "ssl_certificate_arn" {
  description = "SSL certificate ARN"
  value       = module.ecs_fargate_app.ssl_certificate_arn
}