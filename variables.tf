# terraform-aws-ecs-fargate Module Variables
# Following Terraform best practices for variable definitions

#------------------------------------------------------------------------------
# Required Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Base name for all resources. Will be used to create consistent resource naming."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 32
    error_message = "Name must be between 1 and 32 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name))
    error_message = "Name must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod). Used for resource tagging and naming."
  type        = string

  validation {
    condition     = contains(["dev", "development", "test", "staging", "stage", "prod", "production"], var.environment)
    error_message = "Environment must be one of: dev, development, test, staging, stage, prod, production."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created."
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must be a valid VPC identifier starting with 'vpc-'."
  }
}

variable "private_subnets" {
  description = "List of private subnet IDs for ECS tasks. Minimum of 2 subnets required for high availability."
  type        = list(string)

  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "At least 2 private subnets must be provided for high availability."
  }
}

#------------------------------------------------------------------------------
# ALB Configuration
#------------------------------------------------------------------------------

variable "create_alb" {
  description = "Whether to create an Application Load Balancer."
  type        = bool
  default     = true
}

variable "alb_enabled" {
  description = "Enable ALB creation. Used in conjunction with create_alb for conditional logic."
  type        = bool
  default     = true
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB placement. Required if create_alb is true."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.public_subnets) >= 2 || length(var.public_subnets) == 0
    error_message = "If provided, at least 2 public subnets must be specified for ALB high availability."
  }
}

variable "alb_internal" {
  description = "Whether the ALB should be internal (private) or internet-facing."
  type        = bool
  default     = false
}

variable "alb_enable_deletion_protection" {
  description = "Enable deletion protection for the ALB."
  type        = bool
  default     = true
}

variable "alb_enable_http2" {
  description = "Enable HTTP/2 support on the ALB."
  type        = bool
  default     = true
}

variable "alb_enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing for the ALB."
  type        = bool
  default     = true
}

variable "alb_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  type        = number
  default     = 60

  validation {
    condition     = var.alb_idle_timeout >= 1 && var.alb_idle_timeout <= 4000
    error_message = "ALB idle timeout must be between 1 and 4000 seconds."
  }
}

variable "enable_alb_access_logs" {
  description = "Enable access logs for the ALB."
  type        = bool
  default     = false
}

variable "alb_access_logs_bucket" {
  description = "S3 bucket name for ALB access logs. Required if enable_alb_access_logs is true."
  type        = string
  default     = ""
}

variable "alb_access_logs_prefix" {
  description = "S3 prefix for ALB access logs."
  type        = string
  default     = "alb-logs"
}

#------------------------------------------------------------------------------
# ECS Configuration
#------------------------------------------------------------------------------

variable "create_ecs_cluster" {
  description = "Whether to create a new ECS cluster."
  type        = bool
  default     = true
}

variable "create_ecs_service" {
  description = "Whether to create an ECS service."
  type        = bool
  default     = true
}

variable "ecs_cluster_arn" {
  description = "ARN of existing ECS cluster to use. If not provided, a new cluster will be created."
  type        = string
  default     = ""
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the ECS cluster."
  type        = bool
  default     = true
}

variable "task_definition_family" {
  description = "Family name for the ECS task definition. If not provided, will use the base name."
  type        = string
  default     = ""
}

variable "task_cpu" {
  description = "CPU units for the ECS task (1024 = 1 vCPU). Must be compatible with task_memory."
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096, 8192, 16384], var.task_cpu)
    error_message = "Task CPU must be one of: 256, 512, 1024, 2048, 4096, 8192, 16384."
  }
}

variable "task_memory" {
  description = "Memory for the ECS task in MB. Must be compatible with task_cpu."
  type        = number
  default     = 512

  validation {
    condition     = var.task_memory >= 512 && var.task_memory <= 122880
    error_message = "Task memory must be between 512 MB and 122880 MB (120 GB)."
  }
}

variable "container_image" {
  description = "Docker image URI for the container."
  type        = string
  default     = "nginx:latest"
}

variable "container_cpu" {
  description = "CPU units for the container. Must be less than task_cpu."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MB. Must be less than task_memory."
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Port number the container listens on."
  type        = number
  default     = 80

  validation {
    condition     = var.container_port > 0 && var.container_port <= 65535
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "container_environment" {
  description = "Environment variables for the container."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_secrets" {
  description = "Secrets for the container from AWS Systems Manager Parameter Store or AWS Secrets Manager."
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "custom_container_definitions" {
  description = "Custom container definitions. If provided, will override default container configuration."
  type        = any
  default     = null
}

variable "container_health_check" {
  description = "Health check configuration for the container."
  type = object({
    command     = list(string)
    interval    = number
    timeout     = number
    retries     = number
    startPeriod = number
  })
  default = null
}

variable "desired_count" {
  description = "Desired number of ECS tasks to run."
  type        = number
  default     = 2

  validation {
    condition     = var.desired_count >= 0
    error_message = "Desired count must be a non-negative integer."
  }
}

variable "platform_version" {
  description = "Platform version for ECS Fargate tasks."
  type        = string
  default     = "LATEST"
}

variable "assign_public_ip" {
  description = "Whether to assign public IP addresses to ECS tasks."
  type        = bool
  default     = false
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging and troubleshooting."
  type        = bool
  default     = true
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds for ECS service."
  type        = number
  default     = 300

  validation {
    condition     = var.health_check_grace_period >= 0 && var.health_check_grace_period <= 2147483647
    error_message = "Health check grace period must be between 0 and 2147483647 seconds."
  }
}

#------------------------------------------------------------------------------
# Auto Scaling Configuration
#------------------------------------------------------------------------------

variable "enable_auto_scaling" {
  description = "Enable auto scaling for the ECS service."
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum number of tasks for auto scaling."
  type        = number
  default     = 1

  validation {
    condition     = var.min_capacity >= 0
    error_message = "Minimum capacity must be a non-negative integer."
  }
}

variable "max_capacity" {
  description = "Maximum number of tasks for auto scaling."
  type        = number
  default     = 10

  validation {
    condition     = var.max_capacity >= 1
    error_message = "Maximum capacity must be at least 1."
  }
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling."
  type        = number
  default     = 70

  validation {
    condition     = var.cpu_target_value > 0 && var.cpu_target_value <= 100
    error_message = "CPU target value must be between 1 and 100."
  }
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling."
  type        = number
  default     = 80

  validation {
    condition     = var.memory_target_value > 0 && var.memory_target_value <= 100
    error_message = "Memory target value must be between 1 and 100."
  }
}

variable "scale_up_cooldown" {
  description = "Cooldown period in seconds for scaling up."
  type        = number
  default     = 300
}

variable "scale_down_cooldown" {
  description = "Cooldown period in seconds for scaling down."
  type        = number
  default     = 300
}

#------------------------------------------------------------------------------
# Security Configuration
#------------------------------------------------------------------------------

variable "additional_security_groups" {
  description = "Additional security group IDs to attach to ECS tasks."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_task_role" {
  description = "Whether to create an IAM role for ECS tasks."
  type        = bool
  default     = true
}

variable "task_role_policy_arns" {
  description = "List of IAM policy ARNs to attach to the ECS task role."
  type        = list(string)
  default     = []
}

variable "custom_task_role_policy" {
  description = "Custom IAM policy document for the ECS task role."
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# Service Discovery
#------------------------------------------------------------------------------

variable "enable_service_discovery" {
  description = "Enable AWS Cloud Map service discovery."
  type        = bool
  default     = false
}

variable "service_discovery_namespace_id" {
  description = "ID of the service discovery namespace."
  type        = string
  default     = ""
}

variable "service_discovery_dns_ttl" {
  description = "TTL for service discovery DNS records."
  type        = number
  default     = 60
}

#------------------------------------------------------------------------------
# EFS Volumes
#------------------------------------------------------------------------------

variable "efs_volumes" {
  description = "EFS volume configurations for the task definition."
  type = list(object({
    name                    = string
    file_system_id          = string
    root_directory          = optional(string, "/")
    transit_encryption      = optional(string, "ENABLED")
    transit_encryption_port = optional(number, 2049)
    authorization_config = optional(object({
      access_point_id = string
      iam             = string
    }))
  }))
  default = []
}

#------------------------------------------------------------------------------
# Deployment Configuration
#------------------------------------------------------------------------------

variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks that can be running during deployment."
  type        = number
  default     = 200

  validation {
    condition     = var.deployment_maximum_percent >= 100 && var.deployment_maximum_percent <= 200
    error_message = "Deployment maximum percent must be between 100 and 200."
  }
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of tasks that must remain healthy during deployment."
  type        = number
  default     = 100

  validation {
    condition     = var.deployment_minimum_healthy_percent >= 0 && var.deployment_minimum_healthy_percent <= 100
    error_message = "Deployment minimum healthy percent must be between 0 and 100."
  }
}

variable "enable_deployment_circuit_breaker" {
  description = "Enable deployment circuit breaker."
  type        = bool
  default     = true
}

variable "enable_deployment_rollback" {
  description = "Enable automatic rollback on deployment failure."
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# Runtime Platform
#------------------------------------------------------------------------------

variable "runtime_platform" {
  description = "Runtime platform configuration for the task definition."
  type = object({
    operating_system_family = string
    cpu_architecture        = string
  })
  default = null
}

#------------------------------------------------------------------------------
# Monitoring and Logging
#------------------------------------------------------------------------------

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms."
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Number of days to retain CloudWatch logs."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_in_days)
    error_message = "Log retention must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}


#------------------------------------------------------------------------------
# Spot Instance Configuration
#------------------------------------------------------------------------------

variable "enable_spot_instances" {
  description = "Enable Fargate Spot instances for cost optimization with on-demand fallback"
  type        = bool
  default     = false
}

variable "spot_instance_weight" {
  description = "Relative weight for Fargate Spot instances in capacity provider strategy"
  type        = number
  default     = 70

  validation {
    condition     = var.spot_instance_weight >= 0 && var.spot_instance_weight <= 1000
    error_message = "Spot instance weight must be between 0 and 1000."
  }
}

variable "spot_instance_base" {
  description = "Minimum number of tasks to run on Fargate Spot"
  type        = number
  default     = 0
}

variable "on_demand_weight" {
  description = "Relative weight for Fargate on-demand instances in capacity provider strategy"
  type        = number
  default     = 30

  validation {
    condition     = var.on_demand_weight >= 0 && var.on_demand_weight <= 1000
    error_message = "On-demand weight must be between 0 and 1000."
  }
}

variable "on_demand_base" {
  description = "Minimum number of tasks to run on Fargate on-demand (ensures availability)"
  type        = number
  default     = 1
}

variable "default_capacity_provider" {
  description = "Default capacity provider for the ECS cluster"
  type        = string
  default     = "FARGATE"

  validation {
    condition     = contains(["FARGATE", "FARGATE_SPOT"], var.default_capacity_provider)
    error_message = "Default capacity provider must be either FARGATE or FARGATE_SPOT."
  }
}

variable "default_capacity_provider_weight" {
  description = "Weight for the default capacity provider strategy"
  type        = number
  default     = 100
}

variable "default_capacity_provider_base" {
  description = "Base capacity for the default capacity provider strategy"
  type        = number
  default     = 1
}

#------------------------------------------------------------------------------
# Advanced ALB Configuration
#------------------------------------------------------------------------------

variable "ssl_policy" {
  description = "SSL security policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "additional_certificate_arns" {
  description = "Additional SSL certificate ARNs for multi-domain support"
  type        = set(string)
  default     = []
}

variable "host_based_routing_rules" {
  description = "Host-based routing rules for advanced ALB routing"
  type = map(object({
    priority         = number
    host_patterns    = list(string)
    target_group_arn = string
  }))
  default = {}
}

variable "path_based_routing_rules" {
  description = "Path-based routing rules for advanced ALB routing"
  type = map(object({
    priority         = number
    path_patterns    = list(string)
    action_type      = string # forward, redirect, fixed-response
    target_group_arn = optional(string)
    redirect_config = optional(object({
      port        = string
      protocol    = string
      status_code = string
      host        = optional(string)
      path        = optional(string)
      query       = optional(string)
    }))
    fixed_response_config = optional(object({
      content_type = string
      message_body = string
      status_code  = string
    }))
  }))
  default = {}
}

#------------------------------------------------------------------------------
# General Configuration
#------------------------------------------------------------------------------

variable "component" {
  description = "Component name for resource tagging and organization."
  type        = string
  default     = "ecs-fargate"
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# EFS Storage Configuration
#------------------------------------------------------------------------------

variable "enable_efs" {
  description = "Enable EFS (Elastic File System) for persistent storage"
  type        = bool
  default     = false
}

variable "efs_performance_mode" {
  description = "EFS performance mode"
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.efs_performance_mode)
    error_message = "EFS performance mode must be generalPurpose or maxIO."
  }
}

variable "efs_throughput_mode" {
  description = "EFS throughput mode"
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned"], var.efs_throughput_mode)
    error_message = "EFS throughput mode must be bursting or provisioned."
  }
}

variable "efs_provisioned_throughput" {
  description = "Provisioned throughput in MiB/s (only when throughput_mode is provisioned)"
  type        = number
  default     = 100
}

variable "efs_encrypted" {
  description = "Enable EFS encryption at rest"
  type        = bool
  default     = true
}

variable "create_efs_kms_key" {
  description = "Create a dedicated KMS key for EFS encryption"
  type        = bool
  default     = true
}

variable "efs_kms_key_id" {
  description = "Existing KMS key ID for EFS encryption (used when create_efs_kms_key is false)"
  type        = string
  default     = ""
}

variable "efs_kms_key_deletion_window" {
  description = "Deletion window for EFS KMS key in days"
  type        = number
  default     = 7

  validation {
    condition     = var.efs_kms_key_deletion_window >= 7 && var.efs_kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "efs_transition_to_ia" {
  description = "Transition to Infrequent Access storage class"
  type        = string
  default     = "AFTER_30_DAYS"

  validation {
    condition = var.efs_transition_to_ia == "" || contains([
      "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS"
    ], var.efs_transition_to_ia)
    error_message = "EFS transition to IA must be empty or one of the allowed values."
  }
}

variable "efs_transition_to_primary_storage_class" {
  description = "Transition back to primary storage class"
  type        = string
  default     = "AFTER_1_ACCESS"

  validation {
    condition = var.efs_transition_to_primary_storage_class == "" || contains([
      "AFTER_1_ACCESS"
    ], var.efs_transition_to_primary_storage_class)
    error_message = "EFS transition to primary storage class must be empty or AFTER_1_ACCESS."
  }
}

variable "enable_efs_backup" {
  description = "Enable automatic EFS backups"
  type        = bool
  default     = true
}

variable "efs_access_points" {
  description = "EFS access points configuration"
  type = map(object({
    root_directory_path = string
    owner_gid           = number
    owner_uid           = number
    permissions         = string
    posix_gid           = number
    posix_uid           = number
    secondary_gids      = optional(list(number), [])
  }))
  default = {}
}

#------------------------------------------------------------------------------
# S3 Storage Configuration
#------------------------------------------------------------------------------

variable "create_s3_bucket" {
  description = "Create an S3 bucket for application data storage"
  type        = bool
  default     = false
}

variable "s3_force_destroy" {
  description = "Allow S3 bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

variable "s3_versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "s3_kms_key_id" {
  description = "KMS key ID for S3 bucket encryption"
  type        = string
  default     = ""
}

variable "s3_lifecycle_rules" {
  description = "S3 bucket lifecycle rules"
  type = list(object({
    id                                 = string
    status                             = string
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
    transitions = list(object({
      days          = number
      storage_class = string
    }))
  }))
  default = []
}

#------------------------------------------------------------------------------
# DNS and SSL Certificate Configuration
#------------------------------------------------------------------------------

variable "create_ssl_certificate" {
  description = "Create an SSL certificate using AWS Certificate Manager"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Primary domain name for SSL certificate and DNS record"
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "Additional domain names for SSL certificate (SANs)"
  type        = list(string)
  default     = []
}

variable "certificate_validation_method" {
  description = "Certificate validation method (DNS or EMAIL)"
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], var.certificate_validation_method)
    error_message = "Certificate validation method must be DNS or EMAIL."
  }
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for DNS record creation and certificate validation"
  type        = string
  default     = ""
}

variable "create_dns_record" {
  description = "Create a Route53 DNS record pointing to the ALB"
  type        = bool
  default     = false
}

variable "dns_record_name" {
  description = "DNS record name (if different from domain_name)"
  type        = string
  default     = ""
}

variable "dns_record_type" {
  description = "DNS record type"
  type        = string
  default     = "A"

  validation {
    condition     = contains(["A", "AAAA", "CNAME"], var.dns_record_type)
    error_message = "DNS record type must be A, AAAA, or CNAME."
  }
}

variable "dns_record_ttl" {
  description = "TTL for DNS record (only used for non-alias records)"
  type        = number
  default     = 300
}

variable "create_route53_health_check" {
  description = "Create a Route53 health check for the domain"
  type        = bool
  default     = false
}

variable "health_check_port" {
  description = "Port for Route53 health check"
  type        = number
  default     = 443
}

variable "health_check_type" {
  description = "Type of health check (HTTP, HTTPS, TCP)"
  type        = string
  default     = "HTTPS"

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP"], var.health_check_type)
    error_message = "Health check type must be HTTP, HTTPS, or TCP."
  }
}

variable "health_check_resource_path" {
  description = "Resource path for Route53 health check"
  type        = string
  default     = "/"
}

#------------------------------------------------------------------------------
# Monitoring Configuration
#------------------------------------------------------------------------------

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers (e.g., SNS topic ARNs)"
  type        = list(string)
  default     = []
}

variable "create_dashboard" {
  description = "Whether to create a CloudWatch dashboard"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# SSL Certificate Configuration
#------------------------------------------------------------------------------

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener. Required if ALB is created."
  type        = string
  default     = ""
}

variable "health_check_failure_threshold" {
  description = "Number of consecutive health check failures before marking unhealthy"
  type        = number
  default     = 3

  validation {
    condition     = var.health_check_failure_threshold >= 1 && var.health_check_failure_threshold <= 10
    error_message = "Health check failure threshold must be between 1 and 10."
  }
}

variable "health_check_request_interval" {
  description = "Interval between health checks in seconds"
  type        = number
  default     = 30

  validation {
    condition     = contains([10, 30], var.health_check_request_interval)
    error_message = "Health check request interval must be 10 or 30 seconds."
  }
}

#------------------------------------------------------------------------------
# Target Group Configuration
#------------------------------------------------------------------------------

variable "target_group_health_check_enabled" {
  description = "Enable health checks for the target group."
  type        = bool
  default     = true
}

variable "target_group_health_check_interval" {
  description = "Health check interval in seconds."
  type        = number
  default     = 30

  validation {
    condition     = var.target_group_health_check_interval >= 5 && var.target_group_health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds."
  }
}

variable "target_group_health_check_path" {
  description = "Health check path."
  type        = string
  default     = "/health"
}

variable "target_group_health_check_timeout" {
  description = "Health check timeout in seconds."
  type        = number
  default     = 5

  validation {
    condition     = var.target_group_health_check_timeout >= 2 && var.target_group_health_check_timeout <= 120
    error_message = "Health check timeout must be between 2 and 120 seconds."
  }
}

variable "target_group_healthy_threshold" {
  description = "Number of consecutive successful health checks required."
  type        = number
  default     = 2

  validation {
    condition     = var.target_group_healthy_threshold >= 2 && var.target_group_healthy_threshold <= 10
    error_message = "Healthy threshold must be between 2 and 10."
  }
}

variable "target_group_unhealthy_threshold" {
  description = "Number of consecutive failed health checks required."
  type        = number
  default     = 2

  validation {
    condition     = var.target_group_unhealthy_threshold >= 2 && var.target_group_unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2 and 10."
  }
}

variable "target_group_matcher" {
  description = "HTTP status codes that indicate a healthy target."
  type        = string
  default     = "200"
}