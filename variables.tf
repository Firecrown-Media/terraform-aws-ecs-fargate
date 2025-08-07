# Core Configuration
variable "name" {
  description = "Name prefix for all resources"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,32}$", var.name))
    error_message = "Name must be 1-32 characters and contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet IDs for ECS tasks/instances"
  type        = list(string)
}

# ECS Cluster Configuration
variable "cluster_name" {
  description = "Name of the ECS cluster (defaults to var.name if not provided)"
  type        = string
  default     = ""
}

variable "launch_type" {
  description = "Launch type for ECS service (FARGATE or EC2)"
  type        = string
  default     = "FARGATE"
  validation {
    condition     = contains(["FARGATE", "EC2"], var.launch_type)
    error_message = "Launch type must be either FARGATE or EC2."
  }
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}

# Service Configuration
variable "create_service" {
  description = "Whether to create an ECS service"
  type        = bool
  default     = true
}

variable "service_name" {
  description = "Name of the ECS service (defaults to var.name if not provided)"
  type        = string
  default     = ""
}

variable "task_definition_arn" {
  description = "ARN of existing task definition to use (if not provided, a basic one will be created)"
  type        = string
  default     = ""
}

variable "desired_count" {
  description = "Desired number of tasks to run"
  type        = number
  default     = 2
}

variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks that can run during deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of healthy tasks during deployment"
  type        = number
  default     = 100
}

variable "enable_circuit_breaker" {
  description = "Enable deployment circuit breaker"
  type        = bool
  default     = true
}

variable "enable_rollback" {
  description = "Enable automatic rollback on deployment failure"
  type        = bool
  default     = true
}

# Task Definition (when creating a default one)
variable "container_image" {
  description = "Docker image for the container"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port the container exposes"
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "CPU units for the task (Fargate: 256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory for the task in MiB"
  type        = number
  default     = 512
}

variable "container_environment" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_secrets" {
  description = "Secrets for the container from Parameter Store or Secrets Manager"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# EC2 Configuration (when launch_type is EC2)
variable "instance_type" {
  description = "EC2 instance type for ECS cluster"
  type        = string
  default     = "t3.medium"
}

variable "min_size" {
  description = "Minimum number of EC2 instances in auto-scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances in auto-scaling group"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in auto-scaling group"
  type        = number
  default     = 2
}

variable "spot_price" {
  description = "Spot price for EC2 instances (leave empty for on-demand)"
  type        = string
  default     = ""
}

variable "mixed_instances_policy" {
  description = "Enable mixed instances policy for cost optimization"
  type        = bool
  default     = false
}

variable "on_demand_percentage" {
  description = "Percentage of on-demand instances when using mixed instances policy"
  type        = number
  default     = 20
}

variable "spot_instance_types" {
  description = "List of instance types for spot instances"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "m5.large"]
}

# Load Balancer Configuration
variable "create_alb" {
  description = "Whether to create an Application Load Balancer"
  type        = bool
  default     = true
}

variable "alb_name" {
  description = "Name of the ALB (defaults to var.name if not provided)"
  type        = string
  default     = ""
}

variable "alb_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "HTTP status codes for successful health checks"
  type        = string
  default     = "200"
}

# SSL Configuration
variable "certificate_arn" {
  description = "ARN of SSL certificate for HTTPS listener"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "SSL security policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

# Auto Scaling Configuration
variable "enable_autoscaling" {
  description = "Enable auto-scaling for ECS service"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum capacity for auto-scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum capacity for auto-scaling"
  type        = number
  default     = 10
}

variable "target_cpu" {
  description = "Target CPU utilization for auto-scaling"
  type        = number
  default     = 70
}

variable "target_memory" {
  description = "Target memory utilization for auto-scaling"
  type        = number
  default     = 80
}

variable "scale_up_cooldown" {
  description = "Cooldown period for scaling up (seconds)"
  type        = number
  default     = 300
}

variable "scale_down_cooldown" {
  description = "Cooldown period for scaling down (seconds)"
  type        = number
  default     = 300
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable CloudWatch alarms and monitoring"
  type        = bool
  default     = true
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for CloudWatch alarm"
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Memory utilization threshold for CloudWatch alarm"
  type        = number
  default     = 80
}

variable "enable_sns_notifications" {
  description = "Enable SNS notifications for alarms"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for alarm notifications"
  type        = string
  default     = ""
}

# CodeDeploy Configuration
variable "enable_code_deploy" {
  description = "Enable CodeDeploy for Blue/Green deployments"
  type        = bool
  default     = false
}

variable "termination_wait_time_in_minutes" {
  description = "Time to wait before terminating original task set"
  type        = number
  default     = 5
}

# Logging Configuration
variable "log_retention_days" {
  description = "CloudWatch log group retention period in days"
  type        = number
  default     = 7
}

variable "log_group_name" {
  description = "Name of CloudWatch log group (defaults to /aws/ecs/{var.name})"
  type        = string
  default     = ""
}

# EFS Configuration
variable "create_efs" {
  description = "Whether to create an EFS filesystem"
  type        = bool
  default     = false
}

variable "efs_name" {
  description = "Name of the EFS filesystem (defaults to var.name if not provided)"
  type        = string
  default     = ""
}

variable "efs_performance_mode" {
  description = "The file system performance mode (generalPurpose or maxIO)"
  type        = string
  default     = "generalPurpose"
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.efs_performance_mode)
    error_message = "EFS performance mode must be either generalPurpose or maxIO."
  }
}

variable "efs_throughput_mode" {
  description = "The file system throughput mode (bursting or provisioned)"
  type        = string
  default     = "bursting"
  validation {
    condition     = contains(["bursting", "provisioned"], var.efs_throughput_mode)
    error_message = "EFS throughput mode must be either bursting or provisioned."
  }
}

variable "efs_provisioned_throughput" {
  description = "The throughput, measured in MiB/s, for provisioned throughput mode"
  type        = number
  default     = null
}

variable "efs_encrypted" {
  description = "Whether to encrypt the EFS filesystem"
  type        = bool
  default     = true
}

variable "efs_kms_key_id" {
  description = "The ARN for the KMS encryption key for EFS"
  type        = string
  default     = ""
}

variable "efs_backup_policy" {
  description = "EFS backup policy (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.efs_backup_policy)
    error_message = "EFS backup policy must be either ENABLED or DISABLED."
  }
}

variable "efs_lifecycle_policy" {
  description = "EFS lifecycle policy for transitioning files to IA storage class"
  type        = string
  default     = "AFTER_30_DAYS"
  validation {
    condition = contains([
      "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", 
      "AFTER_60_DAYS", "AFTER_90_DAYS", ""
    ], var.efs_lifecycle_policy)
    error_message = "EFS lifecycle policy must be one of: AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, AFTER_90_DAYS, or empty string to disable."
  }
}

variable "efs_mount_targets_subnets" {
  description = "List of subnet IDs for EFS mount targets (defaults to private_subnets if not provided)"
  type        = list(string)
  default     = []
}

variable "efs_access_points" {
  description = "List of EFS access points to create"
  type = list(object({
    name = string
    path = string
    posix_user = optional(object({
      gid = number
      uid = number
      secondary_gids = optional(list(number), [])
    }))
    creation_info = optional(object({
      owner_gid   = number
      owner_uid   = number
      permissions = string
    }))
  }))
  default = []
}

variable "efs_mount_points" {
  description = "List of EFS mount points for container"
  type = list(object({
    source_volume      = string
    container_path     = string
    read_only         = optional(bool, false)
    access_point_id   = optional(string, "")
  }))
  default = []
}