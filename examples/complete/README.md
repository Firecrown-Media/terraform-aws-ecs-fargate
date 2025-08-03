# Complete Example: Full-Featured ECS Fargate Deployment

This example demonstrates a comprehensive ECS Fargate deployment using all available features of the terraform-aws-ecs-fargate module, including:

- **Cost Optimization**: Spot instances with 70/30 Spot/On-Demand mix
- **High Availability**: Auto-scaling with CPU and memory targets
- **Security**: SSL/TLS certificates with DNS validation
- **Storage**: EFS persistent storage with access points and S3 lifecycle management
- **Monitoring**: CloudWatch alarms and Route53 health checks
- **Performance**: Production-ready configuration with blue/green deployments

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet Gateway                       │
└─────────────────┬───────────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────────┐
│                Application Load Balancer                       │
│          (HTTPS with SSL Certificate)                          │
│                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │   Route53   │ │     ALB     │ │   Health    │              │
│  │  DNS Record │ │   Listener  │ │   Checks    │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
└─────────────────┬───────────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────────┐
│                    ECS Fargate Tasks                           │
│              (70% Spot / 30% On-Demand)                       │
│                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │   Task 1    │ │   Task 2    │ │   Task N    │              │
│  │  (Spot)     │ │(On-Demand)  │ │  (Spot)     │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Persistent Storage                         │   │
│  │  ┌─────────────┐ ┌─────────────┐                       │   │
│  │  │     EFS     │ │     S3      │                       │   │
│  │  │  /uploads   │ │ Lifecycle   │                       │   │
│  │  │  /cache     │ │ Management  │                       │   │
│  │  └─────────────┘ └─────────────┘                       │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

Before running this example, ensure you have:

1. **AWS Infrastructure**:
   - VPC with public and private subnets
   - Route53 hosted zone for your domain
   - Appropriate IAM permissions

2. **Terraform Requirements**:
   - Terraform >= 1.6.0
   - AWS Provider >= 5.31.0

3. **Domain Setup**:
   - Domain registered and Route53 hosted zone configured
   - DNS delegation set up properly

## 🚀 Usage

### 1. Configure Variables

Create a `terraform.tfvars` file:

```hcl
# AWS Configuration
aws_region = "us-east-1"

# Domain Configuration  
domain_name = "api.yourdomain.com"
route53_zone_id = "Z1234567890ABC"

# VPC Configuration (use your existing VPC)
vpc_tags = {
  Name = "main-vpc"
}

# Subnet Configuration (use your existing subnets)
private_subnet_tags = {
  Type = "private"
}

public_subnet_tags = {
  Type = "public"
}

# Application Configuration
container_image = "nginx:latest"  # Replace with your application image
desired_count = 2

# Auto Scaling Configuration
min_capacity = 1
max_capacity = 10

# Monitoring Configuration
enable_notifications = true
sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:alerts"
```

### 2. Initialize and Plan

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan the deployment
terraform plan -var-file="terraform.tfvars"
```

### 3. Deploy

```bash
# Apply the configuration
terraform apply -var-file="terraform.tfvars"

# Confirm when prompted
```

### 4. Verify Deployment

After deployment, verify the resources:

```bash
# Check ECS service status
aws ecs describe-services \
  --cluster my-app-prod-cluster \
  --services my-app-prod-service

# Check ALB health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)

# Test the application
curl -I https://api.yourdomain.com/health
```

## 📊 Monitoring and Alerting

This example includes comprehensive monitoring:

### CloudWatch Alarms
- **CPU Utilization**: Alerts when >80% for 2 periods
- **Memory Utilization**: Alerts when >85% for 2 periods  
- **Service Count**: Alerts when running tasks < minimum
- **ALB Response Time**: Alerts when >2 seconds
- **5XX Errors**: Alerts when >10 errors in 5 minutes

### Route53 Health Checks
- **HTTPS Health Check**: Monitors `/health` endpoint
- **Failure Threshold**: 3 consecutive failures
- **Check Interval**: 30 seconds

### Cost Monitoring
- **Spot Instance Usage**: 70% of capacity for cost savings
- **S3 Lifecycle**: Automatic transition to IA and Glacier
- **EFS Lifecycle**: Transition to IA after 30 days

## 🔒 Security Features

### Network Security
- Tasks run in private subnets only
- Security groups with least-privilege access
- HTTPS-only communication with SSL termination

### Data Security
- EFS encryption with customer-managed KMS keys
- S3 encryption and versioning enabled
- Secrets management via AWS Secrets Manager

### Access Control
- Separate IAM roles for task execution and application
- Minimal permissions following AWS best practices
- ECS Exec enabled for secure debugging

## 💰 Cost Optimization

This configuration is optimized for cost efficiency:

### Spot Instances
- **70% Spot capacity** for significant cost savings
- **30% On-Demand** for stability and availability
- **Minimum 1 On-Demand** task for service reliability

### Storage Optimization
- **S3 Lifecycle Rules**: Automatic transition to cheaper storage classes
- **EFS IA Transition**: Files moved to Infrequent Access after 30 days
- **Log Retention**: 30-day retention to control CloudWatch costs

### Right-Sizing
- **Task Resources**: 512 CPU / 1024 MB memory for typical web applications
- **Auto Scaling**: Scales based on actual demand (70% CPU, 80% memory)
- **Health Checks**: Optimized intervals to reduce costs

## 🔧 Customization

### Application-Specific Changes

1. **Container Configuration**:
```hcl
# Update container settings
container_image = "your-ecr-repo/your-app:latest"
container_port = 8080
task_cpu = 1024
task_memory = 2048
```

2. **Environment Variables**:
```hcl
container_environment = [
  {
    name  = "NODE_ENV"
    value = "production"
  },
  {
    name  = "DATABASE_URL"
    value = "postgresql://..."
  }
]
```

3. **Secrets Management**:
```hcl
container_secrets = [
  {
    name      = "DATABASE_PASSWORD"
    valueFrom = "arn:aws:secretsmanager:region:account:secret:db-password"
  }
]
```

### Storage Customization

1. **Additional EFS Access Points**:
```hcl
efs_access_points = {
  data = {
    root_directory_path = "/data"
    owner_gid          = 1000
    owner_uid          = 1000
    permissions        = "755"
    posix_gid          = 1000
    posix_uid          = 1000
  }
  logs = {
    root_directory_path = "/logs"
    owner_gid          = 1000
    owner_uid          = 1000
    permissions        = "750"
    posix_gid          = 1000
    posix_uid          = 1000
  }
}
```

2. **Custom S3 Lifecycle Rules**:
```hcl
s3_lifecycle_rules = [
  {
    id                                 = "custom_retention"
    status                             = "Enabled"
    expiration_days                    = 365
    noncurrent_version_expiration_days = 90
    transitions = [
      {
        days          = 7
        storage_class = "STANDARD_IA"
      },
      {
        days          = 30
        storage_class = "GLACIER"
      },
      {
        days          = 90
        storage_class = "DEEP_ARCHIVE"
      }
    ]
  }
]
```

## 🚀 CI/CD Integration

This example works seamlessly with the module's GitHub Actions workflows:

### Terraform Validation
The module includes comprehensive validation that runs on:
- Pull requests to main branch
- Pushes to main/develop branches
- Manual workflow dispatch

### Security Scanning
Automated security scanning with:
- Checkov for infrastructure security
- TFSec for Terraform-specific issues  
- Semgrep for static analysis
- Trivy for vulnerability scanning

### Quality Gates
All changes must pass:
- Terraform format and validation
- Security scans (no HIGH/CRITICAL findings)
- Linting with TFLint
- Documentation validation

## 📈 Scaling Considerations

### Horizontal Scaling
- **Auto Scaling**: Configured for 1-10 tasks based on CPU/memory
- **Spot Instance Mix**: Maintains availability during spot interruptions
- **Health Checks**: Ensures only healthy tasks receive traffic

### Vertical Scaling
- **Resource Allocation**: Easy to adjust CPU/memory via variables
- **Container Limits**: Prevents resource exhaustion
- **Performance Monitoring**: CloudWatch metrics for optimization

### Geographic Scaling
- **Multi-AZ Deployment**: Tasks distributed across availability zones
- **Regional Considerations**: Easy to deploy in multiple regions
- **DNS Failover**: Route53 health checks support failover scenarios

## 🧹 Cleanup

To destroy the resources:

```bash
# Destroy the infrastructure
terraform destroy -var-file="terraform.tfvars"

# Confirm when prompted
```

**Note**: Some resources like S3 buckets may require manual deletion if they contain data.

## 📚 Additional Resources

- [Main Module Documentation](../../README.md)
- [AWS ECS Fargate Best Practices](https://aws.amazon.com/blogs/containers/aws-fargate-spot-now-generally-available/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## 🤝 Support

If you encounter issues with this example:

1. Check the [troubleshooting guide](../../README.md#-troubleshooting)
2. Review the [GitHub Issues](https://github.com/Firecrown-Media/terraform-aws-ecs-fargate/issues)
3. Ensure your AWS credentials and permissions are properly configured
4. Verify your VPC and subnet configuration matches the requirements