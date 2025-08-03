# terraform-aws-ecs-fargate

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Security](https://img.shields.io/badge/security-scanned-green?style=for-the-badge&logo=security&logoColor=white)](https://github.com/Firecrown-Media/terraform-aws-ecs-fargate/security)
[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)

A comprehensive, production-ready Terraform module for deploying containerized applications on AWS ECS Fargate with Application Load Balancer, auto-scaling, monitoring, security best practices, and comprehensive CI/CD validation.

## 🚀 Features

### Core Infrastructure
- **ECS Fargate Cluster**: Serverless container orchestration with Spot instance support
- **Application Load Balancer**: High-availability HTTP/HTTPS load balancing with advanced routing
- **Auto Scaling**: CPU and memory-based scaling policies with customizable thresholds
- **Service Discovery**: AWS Cloud Map integration for service-to-service communication
- **Security Groups**: Least-privilege network access controls with detailed egress rules

### Security & Compliance
- **IAM Roles**: Separate execution and task roles with minimal permissions
- **ECS Exec**: Secure debugging and troubleshooting capabilities
- **VPC Integration**: Private subnet deployment with controlled internet access
- **SSL/TLS**: HTTPS-only communication with automatic HTTP redirects and certificate management
- **Encryption**: EFS and S3 encryption with customer-managed keys

### Storage & Persistence
- **EFS Integration**: Persistent storage with access points and lifecycle management
- **S3 Storage**: Application data storage with lifecycle policies and versioning
- **Volume Mounts**: Flexible volume mounting for stateful applications

### Monitoring & Observability
- **CloudWatch Logs**: Centralized log aggregation with configurable retention
- **CloudWatch Alarms**: Proactive monitoring for CPU, memory, ALB health, and application metrics
- **CloudWatch Dashboard**: Visual monitoring interface with service and ALB metrics
- **Container Insights**: Enhanced ECS monitoring capabilities with performance metrics

### DevOps & Operations
- **Blue/Green Deployments**: Zero-downtime deployment strategies with circuit breakers
- **Health Checks**: Multi-level health monitoring (ALB, ECS, application)
- **Custom Runtime Platforms**: Support for ARM64 and x86_64 architectures
- **Spot Instances**: Cost optimization with Fargate Spot capacity providers

### Quality Assurance & CI/CD
- **Automated Validation**: Comprehensive GitHub Actions workflows for quality gates
- **Security Scanning**: Multi-tool security analysis with Checkov, TFSec, and Semgrep
- **Code Quality**: TFLint validation and Terraform best practices enforcement
- **Documentation**: Automated documentation generation and validation
- **Multi-Version Testing**: Compatibility testing across Terraform versions

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | >= 5.31.0 |
| random | >= 3.4.0 |

## 🛡️ Providers

| Name | Version |
|------|---------|
| aws | >= 5.31.0 |
| random | >= 3.4.0 |

## 🔄 CI/CD and Quality Assurance

This module includes comprehensive GitHub Actions workflows for quality assurance:

### Terraform Module Validation Workflow

**Trigger Events:**
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

**Quality Gates:**
- ✅ **Terraform Format Check**: Ensures consistent code formatting
- ✅ **Terraform Validation**: Validates configuration syntax and consistency
- ✅ **Security Scanning**: Checkov and TFSec security analysis with SARIF upload
- ✅ **Linting**: TFLint with AWS and Terraform best practices rules
- ✅ **Documentation Validation**: Ensures examples work and docs are current
- ✅ **Version Compatibility**: Tests against Terraform 1.6.0, 1.7.0, 1.8.0, and latest
- ✅ **PR Summary**: Automated comments with validation results

### Advanced Security Scanning Workflow

**Trigger Events:**
- Daily scheduled scans (2 AM UTC)
- Manual dispatch with scan type options (full, quick, compliance-only)

**Security Tools:**
- 🛡️ **Checkov**: Infrastructure security and compliance validation
- 🛡️ **TFSec**: Terraform-specific security issue detection
- 🛡️ **Semgrep**: Static analysis security testing (SAST)
- 🛡️ **Trivy**: Configuration vulnerability scanning
- 🛡️ **Compliance Validation**: AWS Config rules and security group validation

**Security Features:**
- Automated SARIF upload to GitHub Security tab
- Security team notifications on failures
- Comprehensive security reporting
- Compliance validation against AWS best practices

### Running Quality Checks Locally

```bash
# Format check
terraform fmt -check -recursive

# Validation
terraform init -backend=false
terraform validate

# Security scanning (requires tools installation)
checkov -d . --framework terraform
tfsec .

# Linting (requires TFLint installation)
tflint --init
tflint
```

### Contributing Quality Standards

All contributions must pass:
1. Terraform format and validation
2. Security scans (no HIGH or CRITICAL findings)
3. Linting checks (TFLint AWS and Terraform rules)
4. Documentation updates (if applicable)
5. Example validation (if examples are modified)

## 📦 Usage

### Basic Example

```hcl
module "ecs_app" {
  source = "git::https://github.com/Firecrown-Media/terraform-aws-ecs-fargate.git?ref=v1.0.0"

  # Required variables
  name            = "my-application"
  environment     = "production"
  vpc_id          = "vpc-12345678"
  private_subnets = ["subnet-12345678", "subnet-87654321"]
  public_subnets  = ["subnet-11111111", "subnet-22222222"]

  # Container configuration
  container_image = "nginx:latest"
  container_port  = 80
  task_cpu        = 512
  task_memory     = 1024

  # Load balancer
  create_alb            = true
  ssl_certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

  # Auto scaling
  enable_auto_scaling = true
  min_capacity       = 2
  max_capacity       = 10
  cpu_target_value   = 70

  # Monitoring
  enable_monitoring = true
  alarm_actions     = ["arn:aws:sns:us-east-1:123456789012:alerts"]

  tags = {
    Environment = "production"
    Project     = "my-app"
    Owner       = "platform-team"
  }
}
```

### Cost-Optimized Example with Spot Instances

```hcl
module "cost_optimized_app" {
  source = "git::https://github.com/Firecrown-Media/terraform-aws-ecs-fargate.git?ref=v1.0.0"

  name            = "cost-optimized-app"
  environment     = "staging"
  vpc_id          = "vpc-12345678"
  private_subnets = ["subnet-12345678", "subnet-87654321"]
  public_subnets  = ["subnet-11111111", "subnet-22222222"]

  # Container configuration
  container_image = "my-app:latest"
  container_port  = 8080
  task_cpu        = 256
  task_memory     = 512

  # Spot instance configuration for cost savings
  enable_spot_instances = true
  spot_instance_weight  = 70  # 70% Spot instances
  spot_instance_base    = 0   # No minimum Spot instances
  on_demand_weight      = 30  # 30% On-Demand instances
  on_demand_base        = 1   # At least 1 On-Demand for stability

  # Load balancer configuration
  create_alb          = true
  ssl_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/staging-cert"

  # Auto scaling for variable workloads
  enable_auto_scaling = true
  min_capacity        = 1
  max_capacity        = 20
  cpu_target_value    = 60
  memory_target_value = 70

  tags = {
    Environment = "staging"
    Project     = "cost-optimization"
    Owner       = "platform-team"
  }
}
```

### Advanced Example with Persistent Storage

```hcl
module "stateful_app" {
  source = "git::https://github.com/Firecrown-Media/terraform-aws-ecs-fargate.git?ref=v1.0.0"

  name            = "stateful-app"
  environment     = "production"
  vpc_id          = "vpc-12345678"
  private_subnets = ["subnet-12345678", "subnet-87654321"]
  public_subnets  = ["subnet-11111111", "subnet-22222222"]

  # Container configuration
  container_image = "postgres:13"
  container_port  = 5432
  task_cpu        = 1024
  task_memory     = 2048

  # EFS storage for persistent data
  enable_efs           = true
  efs_performance_mode = "generalPurpose"
  efs_throughput_mode  = "bursting"
  efs_encrypted        = true
  create_efs_kms_key   = true
  enable_efs_backup    = true

  # EFS access points for organized data storage
  efs_access_points = {
    data = {
      root_directory_path = "/var/lib/postgresql/data"
      owner_gid          = 999
      owner_uid          = 999
      permissions        = "755"
      posix_gid          = 999
      posix_uid          = 999
      secondary_gids     = []
    }
    backups = {
      root_directory_path = "/backups"
      owner_gid          = 999
      owner_uid          = 999
      permissions        = "750"
      posix_gid          = 999  
      posix_uid          = 999
      secondary_gids     = []
    }
  }

  # S3 storage for backups and logs
  create_s3_bucket      = true
  s3_versioning_enabled = true
  s3_lifecycle_rules = [
    {
      id                                 = "backup_lifecycle"
      status                             = "Enabled"
      expiration_days                    = null
      noncurrent_version_expiration_days = 30
      transitions = [
        {
          days          = 7
          storage_class = "STANDARD_IA"
        },
        {
          days          = 30
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  # Enhanced monitoring for database workloads
  enable_monitoring = true
  create_dashboard  = true
  alarm_actions     = [
    "arn:aws:sns:us-east-1:123456789012:critical-alerts",
    "arn:aws:sns:us-east-1:123456789012:pagerduty"
  ]

  # Custom task role for S3 access
  create_task_role = true
  task_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
  
  custom_task_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::*-backups/*"
      }
    ]
  })

  tags = {
    Environment = "production"
    Project     = "database"
    Owner       = "data-team"
    Backup      = "required"
  }
}
```

### Microservices Example

```hcl
# Shared ECS Cluster
resource "aws_ecs_cluster" "shared" {
  name = "microservices-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# API Service
module "api_service" {
  source = "git::https://github.com/Firecrown-Media/terraform-aws-ecs-fargate.git?ref=v1.0.0"

  name            = "api-service"
  environment     = "production"
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Use existing cluster
  create_ecs_cluster = false
  ecs_cluster_arn    = aws_ecs_cluster.shared.arn

  container_image = "api-service:latest"
  container_port  = 3000
  
  # Public-facing ALB
  create_alb                   = true
  alb_internal                = false
  ssl_certificate_arn         = var.ssl_certificate_arn
  
  # Service discovery for inter-service communication
  enable_service_discovery       = true
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.internal.id

  tags = var.common_tags
}

# Worker Service (no ALB needed)
module "worker_service" {
  source = "git::https://github.com/Firecrown-Media/terraform-aws-ecs-fargate.git?ref=v1.0.0"

  name            = "worker-service"
  environment     = "production"
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets

  create_ecs_cluster = false
  ecs_cluster_arn    = aws_ecs_cluster.shared.arn
  
  # No load balancer for background workers
  create_alb = false

  container_image = "worker-service:latest"
  desired_count   = 3

  # Enhanced auto scaling for batch workloads
  enable_auto_scaling = true
  min_capacity        = 1
  max_capacity        = 50
  cpu_target_value    = 80

  tags = var.common_tags
}

# Database Service with Internal ALB
module "database_service" {
  source = "git::https://github.com/Firecrown-Media/terraform-aws-ecs-fargate.git?ref=v1.0.0"

  name            = "database-service"
  environment     = "production"
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  create_ecs_cluster = false
  ecs_cluster_arn    = aws_ecs_cluster.shared.arn

  container_image = "postgres:13"
  container_port  = 5432
  
  # Internal ALB for secure database access
  create_alb   = true
  alb_internal = true

  # Enable EFS for data persistence
  enable_efs = true
  
  enable_service_discovery       = true
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.internal.id

  tags = var.common_tags
}
```

## 📚 Examples

Check out the [examples](./examples/) directory for complete working examples:

- [**Complete Example**](./examples/complete/) - Full-featured deployment with all options enabled
- [**Migration Example**](./examples/migration/) - Migration patterns from legacy infrastructure

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet Gateway                       │
└─────────────────┬───────────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────────┐
│                    Public Subnets                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Application Load Balancer                  │   │
│  │         (HTTPS/HTTP with SSL Termination)              │   │
│  │                                                         │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │   │
│  │  │   Target    │ │   Target    │ │   Target    │       │   │
│  │  │   Group     │ │   Group     │ │   Group     │       │   │
│  │  │   (HTTP)    │ │  (Redirect) │ │ (Advanced)  │       │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘       │   │
│  └─────────────────┬───────────────────────────────────────┘   │
└─────────────────┬───▼───────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────────┐
│                    Private Subnets                             │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                ECS Fargate Tasks                        │   │
│  │                                                         │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │   │
│  │  │Container │ │Container │ │Container │ │Container │   │   │
│  │  │    1     │ │    2     │ │    3     │ │    N     │   │   │
│  │  │ (Spot)   │ │(On-Demand│ │ (Spot)   │ │ (Spot)   │   │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │   │
│  │                                                         │   │
│  │  ┌─────────────────────────────────────────────────┐   │   │
│  │  │              Auto Scaling                       │   │   │
│  │  │  CPU: 70% | Memory: 80% | Custom Metrics       │   │   │
│  │  └─────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Service Discovery (Cloud Map)              │   │
│  │  api.internal.local  |  worker.internal.local          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  Storage Layer                          │   │
│  │  ┌─────────────┐ ┌─────────────┐                       │   │
│  │  │     EFS     │ │     S3      │                       │   │
│  │  │ (Encrypted) │ │(Lifecycle)  │                       │   │
│  │  └─────────────┘ └─────────────┘                       │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────┬───────────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────────┐
│                    NAT Gateway                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   Monitoring & Logging                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │ CloudWatch  │ │ CloudWatch  │ │ CloudWatch  │              │
│  │    Logs     │ │   Alarms    │ │ Dashboard   │              │
│  │  (30 days)  │ │ (CPU/Mem/   │ │ (Service &  │              │
│  │             │ │  ALB/5XX)   │ │  ALB Views) │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Container Insights                         │   │
│  │        Performance & Security Monitoring               │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## 🔒 Security Best Practices

This module implements comprehensive AWS security best practices:

### Network Security
- **Private Subnets**: ECS tasks run in private subnets with no direct internet access
- **Security Groups**: Least-privilege access with specific port rules and descriptions
- **SSL/TLS**: HTTPS-only communication with modern SSL policies and automatic HTTP redirects
- **VPC Integration**: Full integration with existing VPC infrastructure
- **Network ACLs**: Support for additional network-level access controls

### IAM Security
- **Separate Roles**: Distinct execution and task roles with minimal permissions
- **AWS Managed Policies**: Uses AWS-managed policies where appropriate
- **Custom Policies**: Support for application-specific permissions with policy validation
- **Secrets Management**: Integration with AWS Secrets Manager and Parameter Store
- **Cross-Account Access**: Support for cross-account role assumptions

### Container Security
- **Non-Root User**: Support for containers running as non-root users
- **Read-Only Root**: File system can be mounted as read-only
- **Health Checks**: Multi-level health checking for container and application health
- **Resource Limits**: CPU and memory limits prevent resource exhaustion
- **Security Context**: Configurable security contexts for enhanced isolation

### Data Security
- **Encryption at Rest**: EFS and S3 encryption with customer-managed keys
- **Encryption in Transit**: TLS for all data transmission
- **Key Management**: AWS KMS integration with key rotation
- **Access Logging**: Comprehensive access logging for audit trails
- **Data Classification**: Support for data classification tags

### Monitoring Security
- **Audit Logging**: All AWS API calls are logged via CloudTrail
- **CloudWatch Logs**: Centralized logging with configurable retention
- **Security Alarms**: Monitoring for security-related events and anomalies
- **Container Insights**: Enhanced monitoring for suspicious activities
- **Compliance Reporting**: Built-in compliance monitoring and reporting

## 📈 Monitoring and Observability

### CloudWatch Metrics
- **ECS Service Metrics**: CPU utilization, memory utilization, task count, service events
- **ALB Metrics**: Request count, response time, error rates, target health
- **Auto Scaling Metrics**: Scaling activities, capacity changes, policy triggers
- **Custom Application Metrics**: Support for custom metrics via CloudWatch agent

### CloudWatch Alarms
- **High CPU Utilization**: Configurable CPU threshold alerts (default: 80%)
- **High Memory Utilization**: Configurable memory threshold alerts (default: 85%)
- **Low Task Count**: Alerts when running tasks fall below minimum capacity
- **ALB Health**: Monitors target health, response times, and healthy host count
- **5XX Errors**: Alerts on application errors with configurable thresholds
- **Target Response Time**: Alerts on slow response times (default: 2 seconds)

### CloudWatch Dashboard
- **Service Overview**: Real-time CPU, memory, and task count trends
- **ALB Performance**: Request metrics, response times, and error rates
- **Error Tracking**: 4XX and 5XX error rates with historical trends
- **Auto Scaling**: Scaling events, capacity changes, and utilization trends
- **Cost Optimization**: Spot vs On-Demand instance usage metrics

### Log Aggregation
- **Application Logs**: Structured logging with JSON format recommended
- **Access Logs**: ALB access logs with configurable S3 storage
- **Audit Logs**: ECS and IAM events via CloudTrail integration
- **Retention Policies**: Configurable log retention periods (1-3653 days)
- **Log Streaming**: Support for real-time log streaming to external systems

### Advanced Monitoring Features
- **Container Insights**: Enhanced ECS monitoring with performance analytics
- **X-Ray Tracing**: Distributed tracing support for microservices
- **Custom Dashboards**: Support for custom CloudWatch dashboards
- **Multi-Region Monitoring**: Cross-region monitoring and alerting
- **Cost Monitoring**: Cost allocation tags and budget alerts

## 🚀 Deployment Strategies

### Blue/Green Deployments (Default)
```hcl
# Enabled by default - allows for zero-downtime deployments
deployment_maximum_percent         = 200
deployment_minimum_healthy_percent = 100
enable_deployment_circuit_breaker  = true
enable_deployment_rollback         = true
```

**Benefits:**
- Zero downtime deployments
- Automatic rollback on failures
- Full traffic cutover
- Easy rollback to previous version

### Rolling Updates
```hcl
# Configure for rolling updates with controlled capacity
deployment_maximum_percent         = 150
deployment_minimum_healthy_percent = 50
```

**Benefits:**
- Gradual deployment
- Lower resource usage
- Faster deployments
- Suitable for stateless applications

### Canary Deployments
Use AWS App Mesh, ALB weighted routing, or external tools like Flagger for advanced canary deployments:

```hcl
# Example: ALB weighted routing for canary deployments
path_based_routing_rules = {
  canary = {
    priority      = 100
    path_patterns = ["/api/v2/*"]
    action_type   = "forward"
    target_group_arn = aws_lb_target_group.canary.arn
  }
}
```

### Spot Instance Strategy
```hcl
# Cost-optimized deployment with Spot instances
enable_spot_instances = true
spot_instance_weight  = 70  # 70% Spot capacity
spot_instance_base    = 0   # No minimum Spot instances
on_demand_weight      = 30  # 30% On-Demand capacity  
on_demand_base        = 1   # Minimum 1 On-Demand for stability
```

## 🔧 Troubleshooting

### Common Issues

#### Tasks Not Starting
```bash
# Check service events
aws ecs describe-services --cluster <cluster> --services <service>

# Check task definition
aws ecs describe-task-definition --task-definition <family>

# Check logs
aws logs tail /aws/ecs/<app-name> --follow

# Check task failures
aws ecs list-tasks --cluster <cluster> --service-name <service> --desired-status STOPPED
aws ecs describe-tasks --cluster <cluster> --tasks <task-arn>
```

**Common Causes:**
- Insufficient IAM permissions
- Invalid container image or tag
- Resource constraints (CPU/memory)
- Network connectivity issues
- Health check failures

#### Health Check Failures
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Test health check endpoint locally
curl -f http://localhost:8080/health

# Check health check configuration
aws elbv2 describe-target-groups --target-group-arns <target-group-arn>
```

**Common Causes:**
- Incorrect health check path
- Application not listening on expected port
- Health check timeout too short
- Firewall or security group blocking traffic

#### Auto Scaling Issues
```bash
# Check scaling policies
aws application-autoscaling describe-scaling-policies \
  --service-namespace ecs \
  --resource-id service/<cluster>/<service>

# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=<service> Name=ClusterName,Value=<cluster> \
  --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# Check scaling activities
aws application-autoscaling describe-scaling-activities \
  --service-namespace ecs \
  --resource-id service/<cluster>/<service>
```

**Common Causes:**
- Insufficient scaling permissions
- Metrics not being published
- Scaling policies misconfigured
- Cooldown periods preventing scaling

#### Spot Instance Issues
```bash
# Check capacity provider status
aws ecs describe-capacity-providers --capacity-providers FARGATE_SPOT

# Check service capacity provider strategy
aws ecs describe-services --cluster <cluster> --services <service> \
  --query 'services[0].capacityProviderStrategy'

# Check Spot interruption notices
aws logs filter-log-events \
  --log-group-name /aws/ecs/<cluster> \
  --filter-pattern "SPOT_INTERRUPTION"
```

#### EFS Mount Issues
```bash
# Check EFS mount targets
aws efs describe-mount-targets --file-system-id <efs-id>

# Check EFS security groups
aws efs describe-mount-target-security-groups --mount-target-id <mount-target-id>

# Test EFS connectivity from ECS task
aws ecs execute-command \
  --cluster <cluster> \
  --task <task-id> \
  --container <container> \
  --interactive \
  --command "ls -la /mnt/efs"
```

### Debugging with ECS Exec
```bash
# Ensure ECS Exec is enabled
aws ecs update-service \
  --cluster <cluster> \
  --service <service> \
  --enable-execute-command

# List tasks
aws ecs list-tasks --cluster <cluster> --service-name <service>

# Connect to container
aws ecs execute-command \
  --cluster <cluster> \
  --task <task-id> \
  --container <container-name> \
  --interactive \
  --command "/bin/bash"

# Common debugging commands inside container
ps aux                          # Check running processes
netstat -tlnp                  # Check listening ports  
curl localhost:8080/health     # Test health endpoint
df -h                          # Check disk usage
free -h                        # Check memory usage
env | grep -E "(AWS|DB|API)"   # Check environment variables
```

### Performance Optimization
```bash
# Check CloudWatch Container Insights
aws logs start-query \
  --log-group-name "/aws/containerinsights/<cluster>/performance" \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, TaskDefinitionFamily, ContainerName, CpuUtilized, MemoryUtilized'

# Analyze ALB performance
aws logs start-query \
  --log-group-name "/aws/applicationelb/<alb-name>" \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, target_status_code, response_time | filter response_time > 1000'
```

## 📝 Contributing

We welcome contributions! This module includes comprehensive quality assurance workflows to ensure high standards.

### Development Setup

```bash
# Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/terraform-aws-ecs-fargate.git
cd terraform-aws-ecs-fargate

# Install development tools
brew install terraform terraform-docs tfsec checkov
go install github.com/terraform-linters/tflint@latest

# Configure TFLint
tflint --init
```

### Development Workflow

```bash
# Make your changes and validate
terraform fmt -recursive
terraform validate

# Run security scans
checkov -d . --framework terraform
tfsec .
tflint

# Test with examples
cd examples/complete
terraform init -backend=false
terraform plan -var-file="terraform.tfvars.example"

# Update documentation
terraform-docs markdown table --output-file README.md .

# Create a pull request
git checkout -b feature/your-feature
git commit -m "feat: add amazing new feature"
git push origin feature/your-feature
```

### Quality Standards

All contributions must pass:

✅ **Terraform Format**: `terraform fmt -check -recursive`
✅ **Terraform Validation**: `terraform validate` 
✅ **Security Scanning**: No HIGH or CRITICAL findings in Checkov/TFSec
✅ **Linting**: Pass all TFLint rules for AWS and Terraform best practices
✅ **Documentation**: Update README and variable descriptions
✅ **Examples**: Validate any modified examples work correctly
✅ **Compatibility**: Test against supported Terraform versions

### Automated Quality Gates

The repository includes GitHub Actions workflows that automatically:

- Run all validation checks on pull requests
- Perform comprehensive security scanning
- Test against multiple Terraform versions
- Validate examples and documentation
- Provide detailed feedback on pull requests

### Contribution Types We Welcome

- 🚀 **New Features**: Additional AWS services, enhanced functionality
- 🐛 **Bug Fixes**: Infrastructure issues, configuration problems  
- 📚 **Documentation**: Usage examples, best practices guides
- 🧪 **Testing**: Unit tests, integration tests, example improvements
- 🔒 **Security**: Security enhancements, vulnerability fixes
- 💰 **Cost Optimization**: Spot instance improvements, resource efficiency
- 📊 **Monitoring**: Enhanced observability and alerting

## 📄 License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for more details.

## 🤝 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/Firecrown-Media/terraform-aws-ecs-fargate/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/Firecrown-Media/terraform-aws-ecs-fargate/discussions)
- 📖 **Documentation**: [Wiki](https://github.com/Firecrown-Media/terraform-aws-ecs-fargate/wiki)
- 🔒 **Security**: [Security Policy](SECURITY.md)

## 🙏 Acknowledgments

- AWS ECS Team for excellent documentation and best practices
- Terraform Community for AWS provider development and best practices
- HashiCorp for Terraform and excellent tooling
- Open Source Security Tools (Checkov, TFSec, Semgrep, Trivy)
- Contributors and users who provide feedback and improvements

---

**Made with ❤️ by the Platform Engineering Team**

*This module is production-ready and battle-tested in enterprise environments.*
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.31.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.7.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_appautoscaling_policy.ecs_cpu_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_memory_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_dashboard.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.alb_healthy_host_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.alb_http_5xx_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.alb_target_response_time](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ecs_cpu_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ecs_memory_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ecs_service_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_efs_access_point.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_backup_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_file_system.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_task_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_execution_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_task_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_rule.host_based](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.path_based](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_health_check.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |
| [aws_route53_record.certificate_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.app_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.app_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.app_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.app_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.app_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_service_discovery_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_vpc_security_group_egress_rule.alb_to_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ecs_dns_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ecs_http_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ecs_https_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ecs_ntp_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.efs_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ecs_from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.efs_nfs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_id.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_certificate_arns"></a> [additional\_certificate\_arns](#input\_additional\_certificate\_arns) | Additional SSL certificate ARNs for multi-domain support | `set(string)` | `[]` | no |
| <a name="input_additional_security_groups"></a> [additional\_security\_groups](#input\_additional\_security\_groups) | Additional security group IDs to attach to ECS tasks. | `list(string)` | `[]` | no |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | List of ARNs to notify when alarm triggers (e.g., SNS topic ARNs) | `list(string)` | `[]` | no |
| <a name="input_alb_access_logs_bucket"></a> [alb\_access\_logs\_bucket](#input\_alb\_access\_logs\_bucket) | S3 bucket name for ALB access logs. Required if enable\_alb\_access\_logs is true. | `string` | `""` | no |
| <a name="input_alb_access_logs_prefix"></a> [alb\_access\_logs\_prefix](#input\_alb\_access\_logs\_prefix) | S3 prefix for ALB access logs. | `string` | `"alb-logs"` | no |
| <a name="input_alb_enable_cross_zone_load_balancing"></a> [alb\_enable\_cross\_zone\_load\_balancing](#input\_alb\_enable\_cross\_zone\_load\_balancing) | Enable cross-zone load balancing for the ALB. | `bool` | `true` | no |
| <a name="input_alb_enable_deletion_protection"></a> [alb\_enable\_deletion\_protection](#input\_alb\_enable\_deletion\_protection) | Enable deletion protection for the ALB. | `bool` | `true` | no |
| <a name="input_alb_enable_http2"></a> [alb\_enable\_http2](#input\_alb\_enable\_http2) | Enable HTTP/2 support on the ALB. | `bool` | `true` | no |
| <a name="input_alb_enabled"></a> [alb\_enabled](#input\_alb\_enabled) | Enable ALB creation. Used in conjunction with create\_alb for conditional logic. | `bool` | `true` | no |
| <a name="input_alb_idle_timeout"></a> [alb\_idle\_timeout](#input\_alb\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Whether the ALB should be internal (private) or internet-facing. | `bool` | `false` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access the ALB. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Whether to assign public IP addresses to ECS tasks. | `bool` | `false` | no |
| <a name="input_certificate_validation_method"></a> [certificate\_validation\_method](#input\_certificate\_validation\_method) | Certificate validation method (DNS or EMAIL) | `string` | `"DNS"` | no |
| <a name="input_component"></a> [component](#input\_component) | Component name for resource tagging and organization. | `string` | `"ecs-fargate"` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | CPU units for the container. Must be less than task\_cpu. | `number` | `256` | no |
| <a name="input_container_environment"></a> [container\_environment](#input\_container\_environment) | Environment variables for the container. | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_container_health_check"></a> [container\_health\_check](#input\_container\_health\_check) | Health check configuration for the container. | <pre>object({<br>    command     = list(string)<br>    interval    = number<br>    timeout     = number<br>    retries     = number<br>    startPeriod = number<br>  })</pre> | `null` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Docker image URI for the container. | `string` | `"nginx:latest"` | no |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | Memory for the container in MB. Must be less than task\_memory. | `number` | `512` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port number the container listens on. | `number` | `80` | no |
| <a name="input_container_secrets"></a> [container\_secrets](#input\_container\_secrets) | Secrets for the container from AWS Systems Manager Parameter Store or AWS Secrets Manager. | <pre>list(object({<br>    name      = string<br>    valueFrom = string<br>  }))</pre> | `[]` | no |
| <a name="input_cpu_target_value"></a> [cpu\_target\_value](#input\_cpu\_target\_value) | Target CPU utilization percentage for auto scaling. | `number` | `70` | no |
| <a name="input_create_alb"></a> [create\_alb](#input\_create\_alb) | Whether to create an Application Load Balancer. | `bool` | `true` | no |
| <a name="input_create_dashboard"></a> [create\_dashboard](#input\_create\_dashboard) | Whether to create a CloudWatch dashboard | `bool` | `true` | no |
| <a name="input_create_dns_record"></a> [create\_dns\_record](#input\_create\_dns\_record) | Create a Route53 DNS record pointing to the ALB | `bool` | `false` | no |
| <a name="input_create_ecs_cluster"></a> [create\_ecs\_cluster](#input\_create\_ecs\_cluster) | Whether to create a new ECS cluster. | `bool` | `true` | no |
| <a name="input_create_ecs_service"></a> [create\_ecs\_service](#input\_create\_ecs\_service) | Whether to create an ECS service. | `bool` | `true` | no |
| <a name="input_create_efs_kms_key"></a> [create\_efs\_kms\_key](#input\_create\_efs\_kms\_key) | Create a dedicated KMS key for EFS encryption | `bool` | `true` | no |
| <a name="input_create_route53_health_check"></a> [create\_route53\_health\_check](#input\_create\_route53\_health\_check) | Create a Route53 health check for the domain | `bool` | `false` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Create an S3 bucket for application data storage | `bool` | `false` | no |
| <a name="input_create_ssl_certificate"></a> [create\_ssl\_certificate](#input\_create\_ssl\_certificate) | Create an SSL certificate using AWS Certificate Manager | `bool` | `false` | no |
| <a name="input_create_task_role"></a> [create\_task\_role](#input\_create\_task\_role) | Whether to create an IAM role for ECS tasks. | `bool` | `true` | no |
| <a name="input_custom_container_definitions"></a> [custom\_container\_definitions](#input\_custom\_container\_definitions) | Custom container definitions. If provided, will override default container configuration. | `any` | `null` | no |
| <a name="input_custom_task_role_policy"></a> [custom\_task\_role\_policy](#input\_custom\_task\_role\_policy) | Custom IAM policy document for the ECS task role. | `string` | `""` | no |
| <a name="input_default_capacity_provider"></a> [default\_capacity\_provider](#input\_default\_capacity\_provider) | Default capacity provider for the ECS cluster | `string` | `"FARGATE"` | no |
| <a name="input_default_capacity_provider_base"></a> [default\_capacity\_provider\_base](#input\_default\_capacity\_provider\_base) | Base capacity for the default capacity provider strategy | `number` | `1` | no |
| <a name="input_default_capacity_provider_weight"></a> [default\_capacity\_provider\_weight](#input\_default\_capacity\_provider\_weight) | Weight for the default capacity provider strategy | `number` | `100` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Maximum percentage of tasks that can be running during deployment. | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Minimum percentage of tasks that must remain healthy during deployment. | `number` | `100` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired number of ECS tasks to run. | `number` | `2` | no |
| <a name="input_dns_record_name"></a> [dns\_record\_name](#input\_dns\_record\_name) | DNS record name (if different from domain\_name) | `string` | `""` | no |
| <a name="input_dns_record_ttl"></a> [dns\_record\_ttl](#input\_dns\_record\_ttl) | TTL for DNS record (only used for non-alias records) | `number` | `300` | no |
| <a name="input_dns_record_type"></a> [dns\_record\_type](#input\_dns\_record\_type) | DNS record type | `string` | `"A"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Primary domain name for SSL certificate and DNS record | `string` | `""` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ARN of existing ECS cluster to use. If not provided, a new cluster will be created. | `string` | `""` | no |
| <a name="input_efs_access_points"></a> [efs\_access\_points](#input\_efs\_access\_points) | EFS access points configuration | <pre>map(object({<br>    root_directory_path = string<br>    owner_gid           = number<br>    owner_uid           = number<br>    permissions         = string<br>    posix_gid           = number<br>    posix_uid           = number<br>    secondary_gids      = optional(list(number), [])<br>  }))</pre> | `{}` | no |
| <a name="input_efs_encrypted"></a> [efs\_encrypted](#input\_efs\_encrypted) | Enable EFS encryption at rest | `bool` | `true` | no |
| <a name="input_efs_kms_key_deletion_window"></a> [efs\_kms\_key\_deletion\_window](#input\_efs\_kms\_key\_deletion\_window) | Deletion window for EFS KMS key in days | `number` | `7` | no |
| <a name="input_efs_kms_key_id"></a> [efs\_kms\_key\_id](#input\_efs\_kms\_key\_id) | Existing KMS key ID for EFS encryption (used when create\_efs\_kms\_key is false) | `string` | `""` | no |
| <a name="input_efs_performance_mode"></a> [efs\_performance\_mode](#input\_efs\_performance\_mode) | EFS performance mode | `string` | `"generalPurpose"` | no |
| <a name="input_efs_provisioned_throughput"></a> [efs\_provisioned\_throughput](#input\_efs\_provisioned\_throughput) | Provisioned throughput in MiB/s (only when throughput\_mode is provisioned) | `number` | `100` | no |
| <a name="input_efs_throughput_mode"></a> [efs\_throughput\_mode](#input\_efs\_throughput\_mode) | EFS throughput mode | `string` | `"bursting"` | no |
| <a name="input_efs_transition_to_ia"></a> [efs\_transition\_to\_ia](#input\_efs\_transition\_to\_ia) | Transition to Infrequent Access storage class | `string` | `"AFTER_30_DAYS"` | no |
| <a name="input_efs_transition_to_primary_storage_class"></a> [efs\_transition\_to\_primary\_storage\_class](#input\_efs\_transition\_to\_primary\_storage\_class) | Transition back to primary storage class | `string` | `"AFTER_1_ACCESS"` | no |
| <a name="input_efs_volumes"></a> [efs\_volumes](#input\_efs\_volumes) | EFS volume configurations for the task definition. | <pre>list(object({<br>    name                    = string<br>    file_system_id          = string<br>    root_directory          = optional(string, "/")<br>    transit_encryption      = optional(string, "ENABLED")<br>    transit_encryption_port = optional(number, 2049)<br>    authorization_config = optional(object({<br>      access_point_id = string<br>      iam             = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_enable_alb_access_logs"></a> [enable\_alb\_access\_logs](#input\_enable\_alb\_access\_logs) | Enable access logs for the ALB. | `bool` | `false` | no |
| <a name="input_enable_auto_scaling"></a> [enable\_auto\_scaling](#input\_enable\_auto\_scaling) | Enable auto scaling for the ECS service. | `bool` | `true` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Enable CloudWatch Container Insights for the ECS cluster. | `bool` | `true` | no |
| <a name="input_enable_deployment_circuit_breaker"></a> [enable\_deployment\_circuit\_breaker](#input\_enable\_deployment\_circuit\_breaker) | Enable deployment circuit breaker. | `bool` | `true` | no |
| <a name="input_enable_deployment_rollback"></a> [enable\_deployment\_rollback](#input\_enable\_deployment\_rollback) | Enable automatic rollback on deployment failure. | `bool` | `true` | no |
| <a name="input_enable_efs"></a> [enable\_efs](#input\_enable\_efs) | Enable EFS (Elastic File System) for persistent storage | `bool` | `false` | no |
| <a name="input_enable_efs_backup"></a> [enable\_efs\_backup](#input\_enable\_efs\_backup) | Enable automatic EFS backups | `bool` | `true` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Enable ECS Exec for debugging and troubleshooting. | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable CloudWatch monitoring and alarms. | `bool` | `true` | no |
| <a name="input_enable_service_discovery"></a> [enable\_service\_discovery](#input\_enable\_service\_discovery) | Enable AWS Cloud Map service discovery. | `bool` | `false` | no |
| <a name="input_enable_spot_instances"></a> [enable\_spot\_instances](#input\_enable\_spot\_instances) | Enable Fargate Spot instances for cost optimization with on-demand fallback | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod). Used for resource tagging and naming. | `string` | n/a | yes |
| <a name="input_health_check_failure_threshold"></a> [health\_check\_failure\_threshold](#input\_health\_check\_failure\_threshold) | Number of consecutive health check failures before marking unhealthy | `number` | `3` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Health check grace period in seconds for ECS service. | `number` | `300` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | Port for Route53 health check | `number` | `443` | no |
| <a name="input_health_check_request_interval"></a> [health\_check\_request\_interval](#input\_health\_check\_request\_interval) | Interval between health checks in seconds | `number` | `30` | no |
| <a name="input_health_check_resource_path"></a> [health\_check\_resource\_path](#input\_health\_check\_resource\_path) | Resource path for Route53 health check | `string` | `"/"` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Type of health check (HTTP, HTTPS, TCP) | `string` | `"HTTPS"` | no |
| <a name="input_host_based_routing_rules"></a> [host\_based\_routing\_rules](#input\_host\_based\_routing\_rules) | Host-based routing rules for advanced ALB routing | <pre>map(object({<br>    priority         = number<br>    host_patterns    = list(string)<br>    target_group_arn = string<br>  }))</pre> | `{}` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | Number of days to retain CloudWatch logs. | `number` | `30` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Maximum number of tasks for auto scaling. | `number` | `10` | no |
| <a name="input_memory_target_value"></a> [memory\_target\_value](#input\_memory\_target\_value) | Target memory utilization percentage for auto scaling. | `number` | `80` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | Minimum number of tasks for auto scaling. | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for all resources. Will be used to create consistent resource naming. | `string` | n/a | yes |
| <a name="input_on_demand_base"></a> [on\_demand\_base](#input\_on\_demand\_base) | Minimum number of tasks to run on Fargate on-demand (ensures availability) | `number` | `1` | no |
| <a name="input_on_demand_weight"></a> [on\_demand\_weight](#input\_on\_demand\_weight) | Relative weight for Fargate on-demand instances in capacity provider strategy | `number` | `30` | no |
| <a name="input_path_based_routing_rules"></a> [path\_based\_routing\_rules](#input\_path\_based\_routing\_rules) | Path-based routing rules for advanced ALB routing | <pre>map(object({<br>    priority         = number<br>    path_patterns    = list(string)<br>    action_type      = string # forward, redirect, fixed-response<br>    target_group_arn = optional(string)<br>    redirect_config = optional(object({<br>      port        = string<br>      protocol    = string<br>      status_code = string<br>      host        = optional(string)<br>      path        = optional(string)<br>      query       = optional(string)<br>    }))<br>    fixed_response_config = optional(object({<br>      content_type = string<br>      message_body = string<br>      status_code  = string<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_platform_version"></a> [platform\_version](#input\_platform\_version) | Platform version for ECS Fargate tasks. | `string` | `"LATEST"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet IDs for ECS tasks. Minimum of 2 subnets required for high availability. | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnet IDs for ALB placement. Required if create\_alb is true. | `list(string)` | `[]` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route53 hosted zone ID for DNS record creation and certificate validation | `string` | `""` | no |
| <a name="input_runtime_platform"></a> [runtime\_platform](#input\_runtime\_platform) | Runtime platform configuration for the task definition. | <pre>object({<br>    operating_system_family = string<br>    cpu_architecture        = string<br>  })</pre> | `null` | no |
| <a name="input_s3_force_destroy"></a> [s3\_force\_destroy](#input\_s3\_force\_destroy) | Allow S3 bucket to be destroyed even if it contains objects | `bool` | `false` | no |
| <a name="input_s3_kms_key_id"></a> [s3\_kms\_key\_id](#input\_s3\_kms\_key\_id) | KMS key ID for S3 bucket encryption | `string` | `""` | no |
| <a name="input_s3_lifecycle_rules"></a> [s3\_lifecycle\_rules](#input\_s3\_lifecycle\_rules) | S3 bucket lifecycle rules | <pre>list(object({<br>    id                                 = string<br>    status                             = string<br>    expiration_days                    = optional(number)<br>    noncurrent_version_expiration_days = optional(number)<br>    transitions = list(object({<br>      days          = number<br>      storage_class = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_s3_versioning_enabled"></a> [s3\_versioning\_enabled](#input\_s3\_versioning\_enabled) | Enable S3 bucket versioning | `bool` | `true` | no |
| <a name="input_scale_down_cooldown"></a> [scale\_down\_cooldown](#input\_scale\_down\_cooldown) | Cooldown period in seconds for scaling down. | `number` | `300` | no |
| <a name="input_scale_up_cooldown"></a> [scale\_up\_cooldown](#input\_scale\_up\_cooldown) | Cooldown period in seconds for scaling up. | `number` | `300` | no |
| <a name="input_service_discovery_dns_ttl"></a> [service\_discovery\_dns\_ttl](#input\_service\_discovery\_dns\_ttl) | TTL for service discovery DNS records. | `number` | `60` | no |
| <a name="input_service_discovery_namespace_id"></a> [service\_discovery\_namespace\_id](#input\_service\_discovery\_namespace\_id) | ID of the service discovery namespace. | `string` | `""` | no |
| <a name="input_spot_instance_base"></a> [spot\_instance\_base](#input\_spot\_instance\_base) | Minimum number of tasks to run on Fargate Spot | `number` | `0` | no |
| <a name="input_spot_instance_weight"></a> [spot\_instance\_weight](#input\_spot\_instance\_weight) | Relative weight for Fargate Spot instances in capacity provider strategy | `number` | `70` | no |
| <a name="input_ssl_certificate_arn"></a> [ssl\_certificate\_arn](#input\_ssl\_certificate\_arn) | ARN of the SSL certificate for HTTPS listener. Required if ALB is created. | `string` | `""` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL security policy for HTTPS listener | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | Additional domain names for SSL certificate (SANs) | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_target_group_health_check_enabled"></a> [target\_group\_health\_check\_enabled](#input\_target\_group\_health\_check\_enabled) | Enable health checks for the target group. | `bool` | `true` | no |
| <a name="input_target_group_health_check_interval"></a> [target\_group\_health\_check\_interval](#input\_target\_group\_health\_check\_interval) | Health check interval in seconds. | `number` | `30` | no |
| <a name="input_target_group_health_check_path"></a> [target\_group\_health\_check\_path](#input\_target\_group\_health\_check\_path) | Health check path. | `string` | `"/health"` | no |
| <a name="input_target_group_health_check_timeout"></a> [target\_group\_health\_check\_timeout](#input\_target\_group\_health\_check\_timeout) | Health check timeout in seconds. | `number` | `5` | no |
| <a name="input_target_group_healthy_threshold"></a> [target\_group\_healthy\_threshold](#input\_target\_group\_healthy\_threshold) | Number of consecutive successful health checks required. | `number` | `2` | no |
| <a name="input_target_group_matcher"></a> [target\_group\_matcher](#input\_target\_group\_matcher) | HTTP status codes that indicate a healthy target. | `string` | `"200"` | no |
| <a name="input_target_group_unhealthy_threshold"></a> [target\_group\_unhealthy\_threshold](#input\_target\_group\_unhealthy\_threshold) | Number of consecutive failed health checks required. | `number` | `2` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | CPU units for the ECS task (1024 = 1 vCPU). Must be compatible with task\_memory. | `number` | `256` | no |
| <a name="input_task_definition_family"></a> [task\_definition\_family](#input\_task\_definition\_family) | Family name for the ECS task definition. If not provided, will use the base name. | `string` | `""` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Memory for the ECS task in MB. Must be compatible with task\_cpu. | `number` | `512` | no |
| <a name="input_task_role_policy_arns"></a> [task\_role\_policy\_arns](#input\_task\_role\_policy\_arns) | List of IAM policy ARNs to attach to the ECS task role. | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where resources will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the Application Load Balancer |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the Application Load Balancer |
| <a name="output_alb_hosted_zone_id"></a> [alb\_hosted\_zone\_id](#output\_alb\_hosted\_zone\_id) | Hosted zone ID of the Application Load Balancer (alias for alb\_zone\_id) |
| <a name="output_alb_id"></a> [alb\_id](#output\_alb\_id) | ID of the Application Load Balancer |
| <a name="output_alb_security_group_arn"></a> [alb\_security\_group\_arn](#output\_alb\_security\_group\_arn) | ARN of the ALB security group |
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | ID of the ALB security group |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | Canonical hosted zone ID of the Application Load Balancer |
| <a name="output_application_url"></a> [application\_url](#output\_application\_url) | URL to access the application (ALB DNS name with HTTPS) |
| <a name="output_autoscaling_cpu_policy_arn"></a> [autoscaling\_cpu\_policy\_arn](#output\_autoscaling\_cpu\_policy\_arn) | ARN of the CPU autoscaling policy |
| <a name="output_autoscaling_memory_policy_arn"></a> [autoscaling\_memory\_policy\_arn](#output\_autoscaling\_memory\_policy\_arn) | ARN of the memory autoscaling policy |
| <a name="output_autoscaling_target_resource_id"></a> [autoscaling\_target\_resource\_id](#output\_autoscaling\_target\_resource\_id) | Resource ID of the autoscaling target |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | List of availability zones used |
| <a name="output_capacity_provider_strategy"></a> [capacity\_provider\_strategy](#output\_capacity\_provider\_strategy) | ECS capacity provider strategy configuration |
| <a name="output_cloudwatch_dashboard_url"></a> [cloudwatch\_dashboard\_url](#output\_cloudwatch\_dashboard\_url) | URL of the CloudWatch dashboard |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch log group |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch log group |
| <a name="output_container_image"></a> [container\_image](#output\_container\_image) | Container image being used |
| <a name="output_container_port"></a> [container\_port](#output\_container\_port) | Container port being used |
| <a name="output_cpu_alarm_id"></a> [cpu\_alarm\_id](#output\_cpu\_alarm\_id) | ID of the CPU utilization alarm |
| <a name="output_custom_domain_url"></a> [custom\_domain\_url](#output\_custom\_domain\_url) | URL using custom domain (if DNS record is created) |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS cluster |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ID of the ECS cluster |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | Name of the ECS cluster |
| <a name="output_ecs_security_group_arn"></a> [ecs\_security\_group\_arn](#output\_ecs\_security\_group\_arn) | ARN of the ECS tasks security group |
| <a name="output_ecs_security_group_id"></a> [ecs\_security\_group\_id](#output\_ecs\_security\_group\_id) | ID of the ECS tasks security group |
| <a name="output_ecs_service_arn"></a> [ecs\_service\_arn](#output\_ecs\_service\_arn) | ARN of the ECS service |
| <a name="output_ecs_service_id"></a> [ecs\_service\_id](#output\_ecs\_service\_id) | ID of the ECS service |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | Name of the ECS service |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | ARN of the ECS task definition |
| <a name="output_ecs_task_definition_family"></a> [ecs\_task\_definition\_family](#output\_ecs\_task\_definition\_family) | Family of the ECS task definition |
| <a name="output_ecs_task_definition_revision"></a> [ecs\_task\_definition\_revision](#output\_ecs\_task\_definition\_revision) | Revision of the ECS task definition |
| <a name="output_ecs_task_execution_role_arn"></a> [ecs\_task\_execution\_role\_arn](#output\_ecs\_task\_execution\_role\_arn) | ARN of the ECS task execution role |
| <a name="output_ecs_task_execution_role_name"></a> [ecs\_task\_execution\_role\_name](#output\_ecs\_task\_execution\_role\_name) | Name of the ECS task execution role |
| <a name="output_ecs_task_role_arn"></a> [ecs\_task\_role\_arn](#output\_ecs\_task\_role\_arn) | ARN of the ECS task role |
| <a name="output_ecs_task_role_name"></a> [ecs\_task\_role\_name](#output\_ecs\_task\_role\_name) | Name of the ECS task role |
| <a name="output_efs_access_point_arns"></a> [efs\_access\_point\_arns](#output\_efs\_access\_point\_arns) | ARNs of the EFS access points |
| <a name="output_efs_access_point_ids"></a> [efs\_access\_point\_ids](#output\_efs\_access\_point\_ids) | IDs of the EFS access points |
| <a name="output_efs_dns_name"></a> [efs\_dns\_name](#output\_efs\_dns\_name) | DNS name of the EFS file system |
| <a name="output_efs_file_system_arn"></a> [efs\_file\_system\_arn](#output\_efs\_file\_system\_arn) | ARN of the EFS file system |
| <a name="output_efs_file_system_id"></a> [efs\_file\_system\_id](#output\_efs\_file\_system\_id) | ID of the EFS file system |
| <a name="output_efs_kms_key_arn"></a> [efs\_kms\_key\_arn](#output\_efs\_kms\_key\_arn) | ARN of the EFS KMS key |
| <a name="output_efs_kms_key_id"></a> [efs\_kms\_key\_id](#output\_efs\_kms\_key\_id) | ID of the EFS KMS key |
| <a name="output_efs_security_group_id"></a> [efs\_security\_group\_id](#output\_efs\_security\_group\_id) | ID of the EFS security group |
| <a name="output_health_check_url"></a> [health\_check\_url](#output\_health\_check\_url) | URL for health check endpoint |
| <a name="output_listener_arn"></a> [listener\_arn](#output\_listener\_arn) | ARN of the HTTPS listener |
| <a name="output_memory_alarm_id"></a> [memory\_alarm\_id](#output\_memory\_alarm\_id) | ID of the memory utilization alarm |
| <a name="output_region"></a> [region](#output\_region) | AWS region where resources are deployed |
| <a name="output_route53_health_check_id"></a> [route53\_health\_check\_id](#output\_route53\_health\_check\_id) | ID of the Route53 health check |
| <a name="output_route53_record_fqdn"></a> [route53\_record\_fqdn](#output\_route53\_record\_fqdn) | FQDN of the Route53 DNS record |
| <a name="output_route53_record_name"></a> [route53\_record\_name](#output\_route53\_record\_name) | Name of the Route53 DNS record |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | ARN of the S3 bucket |
| <a name="output_s3_bucket_domain_name"></a> [s3\_bucket\_domain\_name](#output\_s3\_bucket\_domain\_name) | Domain name of the S3 bucket |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | ID of the S3 bucket |
| <a name="output_service_count_alarm_id"></a> [service\_count\_alarm\_id](#output\_service\_count\_alarm\_id) | ID of the service count alarm |
| <a name="output_service_discovery_service_arn"></a> [service\_discovery\_service\_arn](#output\_service\_discovery\_service\_arn) | ARN of the service discovery service |
| <a name="output_service_discovery_service_id"></a> [service\_discovery\_service\_id](#output\_service\_discovery\_service\_id) | ID of the service discovery service |
| <a name="output_service_discovery_service_name"></a> [service\_discovery\_service\_name](#output\_service\_discovery\_service\_name) | Name of the service discovery service |
| <a name="output_spot_instances_enabled"></a> [spot\_instances\_enabled](#output\_spot\_instances\_enabled) | Whether spot instances are enabled |
| <a name="output_ssl_certificate_arn"></a> [ssl\_certificate\_arn](#output\_ssl\_certificate\_arn) | ARN of the SSL certificate |
| <a name="output_ssl_certificate_domain_validation_options"></a> [ssl\_certificate\_domain\_validation\_options](#output\_ssl\_certificate\_domain\_validation\_options) | Domain validation options for the SSL certificate |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the target group |
| <a name="output_target_group_id"></a> [target\_group\_id](#output\_target\_group\_id) | ID of the target group |
| <a name="output_target_group_name"></a> [target\_group\_name](#output\_target\_group\_name) | Name of the target group |
<!-- END_TF_DOCS -->