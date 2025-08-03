# Updated webui.tf - Migrated to use enhanced terraform-aws-ecs-fargate module
# This demonstrates how to use the module with extracted resources from root modules

# Data sources for existing infrastructure
data "aws_acm_certificate" "existing_wildcard" {
  domain   = "*.trains.com"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "trains" {
  name         = "trains.com"
  private_zone = false
}

# Enhanced ECS Fargate module with extracted resources
module "webui_app" {
  source = "../../"

  # Basic configuration
  name        = "${module.this.id}-webui"
  environment = local.env
  component   = "webui"

  # Network configuration
  vpc_id          = var.kalmbach_vpc_id
  private_subnets = var.kalmbach_vpc_private_subnets_id
  public_subnets  = var.kalmbach_vpc_public_subnets_id

  # Container configuration
  container_image = "your-ecr-repo/webui:latest"
  container_port  = var.webui_container_port
  task_cpu        = 512
  task_memory     = 1024
  desired_count   = var.webui_desired_count

  # Spot instance configuration for cost optimization (extracted feature)
  enable_spot_instances = true
  spot_instance_weight  = 70
  spot_instance_base    = 0
  on_demand_weight      = 30
  on_demand_base        = 1

  # Auto scaling configuration (extracted from root modules)
  enable_auto_scaling = true
  min_capacity        = var.webui_min_capacity
  max_capacity        = var.webui_max_capacity
  cpu_target_value    = 70
  memory_target_value = 80

  # ALB configuration (extracted from root modules)
  create_alb                     = true
  alb_enable_deletion_protection = true
  ssl_policy                     = "ELBSecurityPolicy-TLS-1-2-2017-01"

  # Use existing SSL certificate (or create new one)
  ssl_certificate_arn = data.aws_acm_certificate.existing_wildcard.arn
  # Alternative: create new certificate
  # create_ssl_certificate       = true
  # domain_name                  = "webui.trains.com"
  # certificate_validation_method = "DNS"
  # route53_zone_id             = data.aws_route53_zone.trains.zone_id

  # DNS configuration (extracted feature)
  create_dns_record = true
  domain_name       = "webui.trains.com"
  route53_zone_id   = data.aws_route53_zone.trains.zone_id

  # Route53 health checks (extracted feature)
  create_route53_health_check    = true
  health_check_type              = "HTTPS"
  health_check_resource_path     = "/ping"
  health_check_failure_threshold = 3

  # EFS storage configuration (extracted from containers.tf)
  enable_efs           = true
  efs_performance_mode = "generalPurpose"
  efs_throughput_mode  = "bursting"
  efs_encrypted        = true
  create_efs_kms_key   = true
  enable_efs_backup    = true
  efs_transition_to_ia = "AFTER_30_DAYS"

  # EFS access points for application data
  efs_access_points = {
    data = {
      root_directory_path = "/app/data"
      owner_gid           = 1000
      owner_uid           = 1000
      permissions         = "755"
      posix_gid           = 1000
      posix_uid           = 1000
      secondary_gids      = []
    }
    cache = {
      root_directory_path = "/app/cache"
      owner_gid           = 1000
      owner_uid           = 1000
      permissions         = "755"
      posix_gid           = 1000
      posix_uid           = 1000
      secondary_gids      = []
    }
  }

  # S3 storage configuration (extracted feature)
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

  # Target group health checks (extracted configuration)
  target_group_health_check_path     = "/ping"
  target_group_health_check_interval = 20
  target_group_healthy_threshold     = 3
  target_group_unhealthy_threshold   = 2
  target_group_matcher               = "200-399"

  # Container environment variables
  container_environment = [
    {
      name  = "ENVIRONMENT"
      value = local.env
    },
    {
      name  = "DATABASE_HOST"
      value = module.rds.endpoint
    }
  ]

  # Container secrets (using AWS Secrets Manager)
  container_secrets = [
    {
      name      = "DATABASE_PASSWORD"
      valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:app-db-password"
    }
  ]

  # EFS volumes for container (replaces previous EFS mount configuration)
  efs_volumes = [
    {
      name                    = "app-data"
      file_system_id          = module.webui_app.efs_file_system_id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config = {
        access_point_id = module.webui_app.efs_access_point_ids["data"]
        iam             = "ENABLED"
      }
    }
  ]

  # IAM task policy (extracted from previous configuration)
  custom_task_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Scan"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${module.webui_app.s3_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = module.webui_app.s3_bucket_arn
      }
    ]
  })

  # Security configuration
  allowed_cidr_blocks = ["0.0.0.0/0"]

  # Monitoring and logging (extracted from previous configuration)
  enable_monitoring     = true
  log_retention_in_days = 90

  # Note: CI/CD is now handled via GitHub Actions instead of AWS CodePipeline
  # See .github/workflows/deploy-ecs-fargate.yml for application deployment

  # Deployment configuration
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  enable_deployment_circuit_breaker  = true
  enable_deployment_rollback         = true

  # Advanced ALB routing (new extracted feature)
  host_based_routing_rules = {
    admin = {
      priority         = 100
      host_patterns    = ["admin.trains.com"]
      target_group_arn = aws_lb_target_group.admin_app.arn
    }
  }

  path_based_routing_rules = {
    api = {
      priority         = 200
      path_patterns    = ["/api/*"]
      action_type      = "forward"
      target_group_arn = aws_lb_target_group.api_app.arn
    }
  }

  # Tags
  tags = merge(module.this.tags, {
    Component   = "webui"
    Application = "WebApp"
    Environment = local.env
  })
}

# Output the enhanced module results
output "webui_application_url" {
  description = "WebUI application URL"
  value       = module.webui_app.application_url
}

output "webui_custom_domain_url" {
  description = "WebUI custom domain URL"
  value       = module.webui_app.custom_domain_url
}

output "webui_efs_file_system_id" {
  description = "EFS file system ID for WebUI"
  value       = module.webui_app.efs_file_system_id
}

output "webui_s3_bucket_arn" {
  description = "S3 bucket ARN for WebUI data"
  value       = module.webui_app.s3_bucket_arn
}

output "webui_spot_configuration" {
  description = "Spot instance configuration for WebUI"
  value       = module.webui_app.capacity_provider_strategy
}