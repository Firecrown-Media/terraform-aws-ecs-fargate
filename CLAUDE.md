# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive Terraform module for deploying production-ready containerized applications on AWS ECS Fargate. The module provides a complete infrastructure solution with Application Load Balancer, auto-scaling, monitoring, security best practices, and advanced features like Spot instances and persistent storage.

## Architecture

The module is organized into focused, single-responsibility Terraform files:

- `main.tf` - Core ECS cluster, task definition, and service configuration
- `alb.tf` - Application Load Balancer, target groups, listeners, and routing rules
- `autoscaling.tf` - Auto-scaling policies based on CPU and memory utilization
- `security.tf` - IAM roles, policies, and security groups
- `monitoring.tf` - CloudWatch alarms, dashboards, and Container Insights
- `storage.tf` - EFS file systems, S3 buckets, and persistent storage
- `dns.tf` - Route53 DNS records, SSL certificates, and health checks
- `service-discovery.tf` - AWS Cloud Map integration for service-to-service communication
- `variables.tf` - All module input variables with validation
- `outputs.tf` - Module outputs for integration with other infrastructure

## Common Development Commands

### Terraform Operations
```bash
# Format all Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan -var-file="terraform.tfvars"

# Apply changes
terraform apply -var-file="terraform.tfvars"

# Destroy infrastructure
terraform destroy -var-file="terraform.tfvars"
```

### Testing and Validation
```bash
# Security scanning with tfsec
tfsec .

# Generate documentation
terraform-docs markdown table --output-file README.md .

# Validate examples
cd examples/complete
terraform init && terraform plan -var-file="example.tfvars"
```

## Module Configuration Patterns

### Required Variables
Every deployment requires these core variables:
- `name` - Base name for resources (1-32 chars, alphanumeric + hyphens)
- `environment` - Environment name (dev/staging/prod)
- `vpc_id` - Target VPC ID
- `private_subnets` - List of private subnet IDs (minimum 2 for HA)

### Common Configuration Patterns

**Basic Web Application:**
```hcl
module "web_app" {
  source = "./path/to/module"
  
  name            = "my-app"
  environment     = "prod"
  vpc_id          = "vpc-12345678"
  private_subnets = ["subnet-1", "subnet-2"]
  public_subnets  = ["subnet-3", "subnet-4"]
  
  container_image = "nginx:latest"
  container_port  = 80
  task_cpu        = 512
  task_memory     = 1024
}
```

**Microservice (No ALB):**
```hcl
module "worker_service" {
  source = "./path/to/module"
  
  name            = "worker"
  environment     = "prod"
  vpc_id          = "vpc-12345678"
  private_subnets = ["subnet-1", "subnet-2"]
  
  create_alb         = false
  create_ecs_cluster = false
  ecs_cluster_arn    = "existing-cluster-arn"
}
```

### Feature Flags and Conditional Resources

The module uses feature flags to conditionally create resources:
- `create_ecs_cluster` - Create new ECS cluster vs use existing
- `create_ecs_service` - Create ECS service
- `create_alb` - Create Application Load Balancer
- `enable_auto_scaling` - Enable auto-scaling policies
- `enable_monitoring` - Create CloudWatch alarms and dashboard
- `enable_spot_instances` - Use Fargate Spot for cost optimization
- `enable_efs` - Create EFS file system for persistent storage
- `create_ssl_certificate` - Create ACM certificate with DNS validation

### Spot Instance Configuration

For cost optimization, enable Spot instances:
```hcl
enable_spot_instances = true
spot_instance_weight  = 70  # 70% Spot
on_demand_weight     = 30  # 30% On-Demand
on_demand_base       = 1   # Minimum 1 On-Demand task
```

### Advanced Routing

The ALB supports sophisticated routing rules:
```hcl
host_based_routing_rules = {
  "api" = {
    priority         = 100
    host_patterns    = ["api.example.com"]
    target_group_arn = aws_lb_target_group.api.arn
  }
}

path_based_routing_rules = {
  "health" = {
    priority      = 200
    path_patterns = ["/health", "/status"]
    action_type   = "fixed-response"
    fixed_response_config = {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
}
```

## Security Best Practices

### IAM Roles
- Separate execution and task roles with minimal permissions
- Task execution role: `ecs_task_execution_role_arn`
- Task role: `ecs_task_role_arn` (optional, created when `create_task_role = true`)

### Network Security
- ECS tasks run in private subnets only
- Security groups follow least-privilege principles
- ALB security group allows 80/443 inbound, container port outbound to ECS
- ECS security group allows container port inbound from ALB only

### SSL/TLS
- HTTPS-only configuration with HTTP→HTTPS redirects
- Modern SSL policies (default: `ELBSecurityPolicy-TLS-1-2-2017-01`)
- ACM certificate with DNS validation support

## Container Configuration

### Environment Variables vs Secrets
```hcl
container_environment = [
  {
    name  = "NODE_ENV"
    value = "production"
  }
]

container_secrets = [
  {
    name      = "DATABASE_PASSWORD"
    valueFrom = "arn:aws:secretsmanager:region:account:secret:name"
  }
]
```

### Health Checks
Default health check uses curl against `/health` endpoint:
```hcl
container_health_check = {
  command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/health || exit 1"]
  interval    = 30
  timeout     = 5
  retries     = 3
  startPeriod = 60
}
```

## Monitoring and Observability

### CloudWatch Integration
- Automatic log group creation: `/aws/ecs/${name}`
- Container Insights enabled by default
- CPU and memory utilization alarms
- Auto-scaling based on CloudWatch metrics

### Available Metrics
- `AWS/ECS` namespace: CPUUtilization, MemoryUtilization
- `AWS/ApplicationELB` namespace: TargetResponseTime, HTTPCode_*
- Custom application metrics via CloudWatch agent

## Storage Options

### EFS (Elastic File System)
```hcl
enable_efs = true
efs_volumes = [
  {
    name           = "shared-storage"
    file_system_id = module.efs.file_system_id
    root_directory = "/app/data"
  }
]
```

### S3 Integration
```hcl
create_s3_bucket = true
s3_lifecycle_rules = [
  {
    id     = "archive"
    status = "Enabled"
    transitions = [
      {
        days          = 30
        storage_class = "STANDARD_IA"
      }
    ]
  }
]
```

## Deployment Strategies

### Blue/Green (Default)
```hcl
deployment_maximum_percent         = 200
deployment_minimum_healthy_percent = 100
enable_deployment_circuit_breaker  = true
enable_deployment_rollback         = true
```

### Rolling Updates
```hcl
deployment_maximum_percent         = 150
deployment_minimum_healthy_percent = 50
```

## Troubleshooting

### Common Issues
1. **Tasks not starting**: Check CloudWatch logs at `/aws/ecs/${name}`
2. **Health check failures**: Verify target group health check path matches application
3. **Auto-scaling not working**: Ensure CloudWatch metrics are being published
4. **SSL certificate validation**: Check Route53 DNS records for ACM validation

### Debug Commands
```bash
# Check ECS service status
aws ecs describe-services --cluster <cluster> --services <service>

# View recent logs
aws logs tail /aws/ecs/<app-name> --follow

# Check target group health
aws elbv2 describe-target-health --target-group-arn <arn>

# Use ECS Exec for container debugging (when enable_execute_command = true)
aws ecs execute-command --cluster <cluster> --task <task-id> --container <container> --interactive --command "/bin/bash"
```

## Examples Directory

- `examples/complete/` - Full-featured deployment with all options enabled
- `examples/migration/` - Migration patterns and updated configurations
- `examples/wordpress/` - WordPress-specific container setup

## Module Outputs

Key outputs for integration:
- `application_url` - HTTPS URL to access the application
- `ecs_cluster_arn` - For additional services in same cluster
- `alb_dns_name` - For DNS record creation
- `ecs_security_group_id` - For additional security group rules
- `cloudwatch_log_group_name` - For log shipping configuration