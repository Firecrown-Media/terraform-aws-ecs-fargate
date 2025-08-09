variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "complex-ecs-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_name" {
  description = "Name of the existing VPC"
  type        = string
  default     = "main-vpc"
}

variable "notification_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = ""
}

# Container Configuration
variable "container_image" {
  description = "Docker image for the container"
  type        = string
  default     = "httpd:latest"
}

variable "container_port" {
  description = "Port the container exposes"
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "Memory for the task in MiB"
  type        = number
  default     = 2048
}

variable "container_environment" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "LOG_LEVEL"
      value = "info"
    }
  ]
}

variable "container_secrets" {
  description = "Secrets for the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# Service Configuration
variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 3
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 20
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 3
}

variable "on_demand_percentage" {
  description = "Percentage of on-demand instances"
  type        = number
  default     = 30
}

variable "spot_instance_types" {
  description = "List of instance types for spot instances"
  type        = list(string)
  default     = ["t3.large", "t3.xlarge", "m5.large", "m5.xlarge", "c5.large", "c5.xlarge"]
}

# Load Balancer Configuration
variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "certificate_arn" {
  description = "ARN of SSL certificate"
  type        = string
  default     = ""
}

# Auto Scaling Configuration
variable "autoscaling_min_capacity" {
  description = "Minimum capacity for ECS service auto-scaling"
  type        = number
  default     = 2
}

variable "autoscaling_max_capacity" {
  description = "Maximum capacity for ECS service auto-scaling"
  type        = number
  default     = 20
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization for auto-scaling"
  type        = number
  default     = 60
}

variable "target_memory_utilization" {
  description = "Target memory utilization for auto-scaling"
  type        = number
  default     = 70
}

# CodeDeploy Configuration
variable "enable_code_deploy" {
  description = "Enable CodeDeploy for Blue/Green deployments"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention period"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    project     = "ComplexECSApp"
    environment = "prod"
    cost-center = "Engineering"
    owner       = "DevOps Team"
  }
}