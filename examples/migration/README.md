# Migration Example: WordPress Application Migration to Enhanced Module

This example demonstrates how to migrate an existing WordPress application to use the enhanced terraform-aws-ecs-fargate module with extracted resources and features. It shows the migration path from legacy configurations to the modern, feature-rich module.

## 🔄 Migration Overview

This migration example shows how to:

- **Migrate from Legacy ECS Setup**: Transform existing ECS configurations to use the enhanced module
- **Integrate Extracted Features**: Leverage Spot instances, advanced ALB routing, EFS storage, and SSL management
- **Maintain Compatibility**: Preserve existing functionality while adding new capabilities
- **Optimize Costs**: Implement Spot instance strategies and storage lifecycle management
- **Enhance Security**: Add SSL certificates, health checks, and improved IAM policies

## 📊 Before vs After Comparison

### Before (Legacy Configuration)
```
┌─────────────────────────────────────────────────────────────────┐
│                     Legacy ECS Setup                           │
│                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │    ALB      │ │    ECS      │ │    RDS      │              │
│  │  (Basic)    │ │ (On-Demand) │ │ (Separate)  │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
│                                                                 │
│  Limited scaling • Basic monitoring • Manual SSL management    │
└─────────────────────────────────────────────────────────────────┘
```

### After (Enhanced Module)
```
┌─────────────────────────────────────────────────────────────────┐
│                  Enhanced ECS Fargate Module                   │
│                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │     ALB     │ │     ECS     │ │    Storage  │              │
│  │ Advanced    │ │Spot/OnDemand│ │  EFS + S3   │              │
│  │ Routing     │ │Auto-Scaling │ │ Lifecycle   │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
│                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │    SSL      │ │   Health    │ │ Monitoring  │              │
│  │   + DNS     │ │   Checks    │ │   + Alerts  │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## 🎯 Key Migration Benefits

### Cost Optimization
- **70% Cost Savings**: Spot instances reduce compute costs significantly
- **Storage Efficiency**: S3 lifecycle rules and EFS IA transitions
- **Right-Sizing**: Auto-scaling based on actual demand

### Enhanced Reliability
- **High Availability**: Multi-AZ deployment with health checks
- **Zero-Downtime Deployments**: Blue/green deployment strategy
- **Automatic Recovery**: Circuit breakers and rollback capabilities

### Improved Security
- **SSL/TLS Encryption**: Automated certificate management
- **Network Security**: Private subnets with security groups
- **Data Encryption**: EFS and S3 encryption at rest

### Better Monitoring
- **Comprehensive Alarms**: CPU, memory, ALB, and application metrics
- **Health Monitoring**: Route53 health checks and ALB target health
- **Performance Insights**: CloudWatch dashboards and Container Insights

## 📋 Migration Prerequisites

Before migrating, ensure you have:

1. **Existing Infrastructure Assessment**:
   - Current ECS cluster and service configuration
   - Database connection details (RDS endpoint)
   - SSL certificate ARNs (if using existing certificates)
   - Route53 hosted zone configuration

2. **Access Requirements**:
   - AWS credentials with appropriate permissions
   - Access to existing secrets in AWS Secrets Manager
   - Route53 zone management permissions

3. **Application Readiness**:
   - Container image available in ECR or public registry
   - Health check endpoint configured (`/ping` or `/health`)
   - Environment variables and secrets identified

## 🚀 Migration Steps

### Step 1: Prepare the Migration

1. **Backup Current Configuration**:
```bash
# Export current ECS service configuration
aws ecs describe-services --cluster your-cluster --services your-service > current-service.json

# Export current task definition
aws ecs describe-task-definition --task-definition your-task-def > current-task-def.json
```

2. **Identify Dependencies**:
```bash
# List current resources
terraform state list

# Check for dependencies
terraform show
```

### Step 2: Configure the Enhanced Module

Update your Terraform configuration to use the enhanced module:

```hcl
# Replace existing ECS configuration with enhanced module
module "webui_app" {
  source = "git::https://github.com/Firecrown-Media/terraform-aws-ecs-fargate.git?ref=v1.0.0"

  # Basic configuration (migrated from existing)
  name        = "${module.this.id}-webui"
  environment = local.env
  component   = "webui"

  # Network configuration (use existing VPC)
  vpc_id          = var.kalmbach_vpc_id
  private_subnets = var.kalmbach_vpc_private_subnets_id
  public_subnets  = var.kalmbach_vpc_public_subnets_id

  # Container configuration (migrate existing settings)
  container_image = "your-ecr-repo/webui:latest"
  container_port  = var.webui_container_port
  task_cpu        = 512
  task_memory     = 1024
  desired_count   = var.webui_desired_count

  # NEW: Cost optimization with Spot instances
  enable_spot_instances = true
  spot_instance_weight  = 70
  spot_instance_base    = 0
  on_demand_weight      = 30
  on_demand_base        = 1

  # NEW: Auto scaling
  enable_auto_scaling = true
  min_capacity        = var.webui_min_capacity
  max_capacity        = var.webui_max_capacity
  cpu_target_value    = 70
  memory_target_value = 80

  # NEW: Enhanced ALB features
  create_alb                     = true
  alb_enable_deletion_protection = true
  ssl_policy                     = "ELBSecurityPolicy-TLS-1-2-2017-01"

  # NEW: SSL and DNS management
  ssl_certificate_arn = data.aws_acm_certificate.existing_wildcard.arn
  create_dns_record   = true
  domain_name         = "webui.trains.com"
  route53_zone_id     = data.aws_route53_zone.trains.zone_id

  # NEW: Persistent storage
  enable_efs           = true
  efs_performance_mode = "generalPurpose"
  efs_throughput_mode  = "bursting"
  efs_encrypted        = true
  create_efs_kms_key   = true

  # NEW: Enhanced monitoring
  enable_monitoring = true
  create_dashboard  = true
  
  tags = merge(module.this.tags, {
    Component   = "webui"
    Application = "WordPress"
    Environment = local.env
  })
}
```

### Step 3: Plan the Migration

```bash
# Initialize with new module
terraform init -upgrade

# Plan the migration
terraform plan -var-file="terraform.tfvars"

# Review the plan carefully - look for:
# - Resources being replaced vs modified
# - Any data loss risks (especially databases)
# - Network connectivity changes
```

### Step 4: Execute Migration

For a safe migration, consider using Terraform's targeted approach:

```bash
# Apply infrastructure changes first (VPC, security groups)
terraform apply -target=module.webui_app.aws_security_group.ecs_tasks

# Apply ALB changes
terraform apply -target=module.webui_app.aws_lb.main

# Apply ECS changes last
terraform apply -target=module.webui_app.aws_ecs_service.main

# Apply remaining resources
terraform apply
```

### Step 5: Verify Migration

After migration, verify all components:

```bash
# Check ECS service health
aws ecs describe-services \
  --cluster ${terraform output -raw ecs_cluster_name} \
  --services ${terraform output -raw ecs_service_name}

# Test application endpoint
curl -I $(terraform output -raw application_url)

# Check SSL certificate
openssl s_client -connect webui.trains.com:443 -servername webui.trains.com

# Verify health checks
aws route53 get-health-check \
  --health-check-id $(terraform output -raw route53_health_check_id)
```

## 🔧 Migration Specific Features

### WordPress Configuration

This migration example includes WordPress-specific optimizations:

#### EFS Access Points
```hcl
efs_access_points = {
  uploads = {
    root_directory_path = "/var/www/html/wp-content/uploads"
    owner_gid           = 33 # www-data
    owner_uid           = 33 # www-data
    permissions         = "755"
    posix_gid           = 33
    posix_uid           = 33
    secondary_gids      = []
  }
  cache = {
    root_directory_path = "/var/www/html/wp-content/cache"
    owner_gid           = 33
    owner_uid           = 33
    permissions         = "755"
    posix_gid           = 33
    posix_uid           = 33
    secondary_gids      = []
  }
}
```

#### Advanced ALB Routing
```hcl
# Route admin traffic to separate target group
host_based_routing_rules = {
  admin = {
    priority         = 100
    host_patterns    = ["admin.trains.com"]
    target_group_arn = aws_lb_target_group.admin_app.arn
  }
}

# Route API traffic to different backend
path_based_routing_rules = {
  api = {
    priority         = 200
    path_patterns    = ["/api/*"]
    action_type      = "forward"
    target_group_arn = aws_lb_target_group.api_app.arn
  }
}
```

#### Database Integration
```hcl
container_environment = [
  {
    name  = "WORDPRESS_DB_HOST"
    value = module.rds.endpoint
  }
]

container_secrets = [
  {
    name      = "WORDPRESS_DB_PASSWORD"
    valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:wordpress-db-password"
  }
]
```

## 🚨 Migration Considerations

### Downtime Planning
- **Blue/Green Strategy**: The module supports zero-downtime deployments
- **DNS TTL**: Lower TTL values before migration for faster failback
- **Health Checks**: Configure appropriate grace periods for startup

### Data Migration
- **EFS Data**: Existing EFS can be integrated by providing `file_system_id`
- **S3 Data**: Existing buckets can be imported or data migrated
- **Database**: RDS remains separate and unaffected

### Rollback Strategy
```bash
# Quick rollback using Terraform state
terraform apply -target=module.webui_app.aws_ecs_service.main \
  -var="desired_count=0"

# Full rollback to previous state
terraform apply -refresh=false -var-file="rollback.tfvars"
```

### Performance Considerations
- **Spot Instance Interruptions**: Monitor for interruption notices
- **Auto Scaling**: Allow time for metrics to stabilize
- **Health Checks**: Tune thresholds based on application behavior

## 📊 Post-Migration Monitoring

### Key Metrics to Watch
1. **Application Performance**:
   - Response times via ALB metrics
   - Error rates (4XX/5XX)
   - Task start/stop events

2. **Cost Optimization**:
   - Spot instance usage vs On-Demand
   - Auto-scaling activities
   - Storage costs (EFS/S3)

3. **Reliability**:
   - Health check success rates
   - Service availability
   - Task failure reasons

### CloudWatch Dashboards
The module automatically creates comprehensive dashboards showing:
- ECS service metrics (CPU, memory, task count)
- ALB performance (response time, error rates)
- Auto-scaling activities
- Cost optimization metrics

## 🔄 Continuous Improvement

After successful migration:

1. **Monitor for 1-2 weeks**: Establish baseline performance metrics
2. **Optimize Auto-Scaling**: Adjust thresholds based on actual usage
3. **Review Costs**: Analyze cost savings and optimize further
4. **Security Review**: Implement additional security controls as needed
5. **Documentation**: Update runbooks and operational procedures

## 🤝 Support and Troubleshooting

### Common Migration Issues

1. **Task Startup Failures**:
```bash
# Check task definition and container logs
aws ecs describe-tasks --cluster CLUSTER --tasks TASK_ARN
aws logs tail /aws/ecs/your-app --follow
```

2. **Health Check Failures**:
```bash
# Test health endpoint directly
curl -v http://internal-alb-endpoint/ping

# Check target group health
aws elbv2 describe-target-health --target-group-arn TARGET_GROUP_ARN
```

3. **DNS Resolution Issues**:
```bash
# Test DNS resolution
nslookup webui.trains.com

# Check Route53 records
aws route53 list-resource-record-sets --hosted-zone-id ZONE_ID
```

### Getting Help
- [Main Module Documentation](../../README.md)
- [GitHub Issues](https://github.com/Firecrown-Media/terraform-aws-ecs-fargate/issues)
- [AWS ECS Troubleshooting Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/troubleshooting.html)

## 📚 Additional Resources

- [WordPress on ECS Best Practices](https://aws.amazon.com/blogs/containers/wordpress-high-availability-amazon-ecs/)
- [Spot Instance Best Practices](https://aws.amazon.com/ec2/spot/best-practices/)
- [EFS Performance Guide](https://docs.aws.amazon.com/efs/latest/ug/performance.html)
- [ALB Advanced Routing](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-rules.html)