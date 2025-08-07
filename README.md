# AWS ECS Terraform Module

A comprehensive, production-ready Terraform module for deploying containerized applications on AWS Elastic Container Service (ECS). This module supports both Fargate and EC2 launch types, with extensive configuration options for networking, auto-scaling, monitoring, and Blue/Green deployments.

## Features

### 🚀 **Launch Types**
- **AWS Fargate** (default) - Serverless container compute
- **EC2** - Full control with cost optimization through Spot instances

### 🔄 **Auto Scaling & High Availability**
- ECS Service auto-scaling based on CPU, memory, and ALB request count
- EC2 Auto Scaling Groups with mixed instances policy
- Multi-AZ deployment for high availability
- Rolling updates with configurable health checks

### 🌐 **Networking**
- Application Load Balancer with SSL/TLS support
- Advanced routing and health checks
- Security groups following least-privilege principles
- Support for internal and internet-facing load balancers

### 📊 **Monitoring & Observability**
- CloudWatch Container Insights
- Comprehensive CloudWatch alarms and dashboards
- SNS notifications for critical alerts
- Pre-configured Log Insights queries
- ECS Events integration

### 🔄 **Deployment Strategies**
- Blue/Green deployments with AWS CodeDeploy
- Circuit breaker and automatic rollback
- Configurable deployment parameters

### 💰 **Cost Optimization**
- Spot instance integration for EC2 launch type
- Mixed instances policy (On-Demand + Spot)
- Right-sizing recommendations through monitoring

### 🔐 **Security Best Practices**
- IAM roles with least-privilege access
- Container tasks in private subnets
- Secrets management via AWS Systems Manager/Secrets Manager
- Modern SSL policies and security groups

## Quick Start

### Simple Fargate Deployment

```hcl
module "ecs_app" {
  source = "path/to/this/module"

  name            = "my-app"
  environment     = "prod"
  vpc_id          = "vpc-12345678"
  private_subnets = ["subnet-12345678", "subnet-87654321"]
  public_subnets  = ["subnet-abcdefgh", "subnet-hgfedcba"]
  
  container_image = "nginx:latest"
  container_port  = 80
  desired_count   = 2
  
  create_alb      = true
  certificate_arn = "arn:aws:acm:region:account:certificate/cert-id"
  
  enable_autoscaling = true
  min_capacity      = 1
  max_capacity      = 10
}
```

### Advanced EC2 with Spot Instances

```hcl
module "ecs_app_advanced" {
  source = "path/to/this/module"

  name            = "my-app"
  environment     = "prod"
  vpc_id          = "vpc-12345678"
  private_subnets = ["subnet-12345678", "subnet-87654321"]
  public_subnets  = ["subnet-abcdefgh", "subnet-hgfedcba"]
  
  # EC2 Configuration
  launch_type            = "EC2"
  instance_type          = "t3.large"
  mixed_instances_policy = true
  on_demand_percentage   = 20
  spot_instance_types    = ["t3.large", "m5.large", "c5.large"]
  
  # Application
  container_image = "my-app:latest"
  container_port  = 8080
  task_cpu        = 1024
  task_memory     = 2048
  
  # High Availability
  desired_count          = 3
  min_capacity          = 2
  max_capacity          = 20
  enable_autoscaling    = true
  
  # Blue/Green Deployment
  enable_code_deploy = true
  
  # Full Monitoring
  enable_monitoring         = true
  enable_sns_notifications = true
  sns_topic_arn           = "arn:aws:sns:region:account:alerts"
}
```

## Module Structure

```
├── main.tf                 # Core ECS resources
├── variables.tf           # Input variables
├── outputs.tf             # Module outputs  
├── networking.tf          # ALB, security groups
├── autoscaling.tf         # Auto scaling configuration
├── monitoring.tf          # CloudWatch alarms and dashboards
├── iam.tf                # IAM roles and policies
├── user_data.sh          # EC2 instance initialization
├── versions.tf           # Terraform version requirements
└── examples/
    ├── simple/           # Basic Fargate example
    └── complex/          # Advanced EC2 example
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for all resources | `string` | n/a | yes |
| vpc_id | VPC ID where resources will be created | `string` | n/a | yes |
| private_subnets | List of private subnet IDs for ECS tasks/instances | `list(string)` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| public_subnets | List of public subnet IDs for ALB | `list(string)` | `[]` | no |
| launch_type | Launch type for ECS service (FARGATE or EC2) | `string` | `"FARGATE"` | no |
| container_image | Docker image for the container | `string` | `"nginx:latest"` | no |
| container_port | Port the container exposes | `number` | `80` | no |
| task_cpu | CPU units for the task | `number` | `256` | no |
| task_memory | Memory for the task in MiB | `number` | `512` | no |
| desired_count | Desired number of tasks to run | `number` | `2` | no |
| create_alb | Whether to create an Application Load Balancer | `bool` | `true` | no |
| certificate_arn | ARN of SSL certificate for HTTPS listener | `string` | `""` | no |
| enable_autoscaling | Enable auto-scaling for ECS service | `bool` | `true` | no |
| min_capacity | Minimum capacity for auto-scaling | `number` | `1` | no |
| max_capacity | Maximum capacity for auto-scaling | `number` | `10` | no |
| target_cpu | Target CPU utilization for auto-scaling | `number` | `70` | no |
| target_memory | Target memory utilization for auto-scaling | `number` | `80` | no |
| enable_monitoring | Enable CloudWatch alarms and monitoring | `bool` | `true` | no |
| enable_sns_notifications | Enable SNS notifications for alarms | `bool` | `false` | no |
| sns_topic_arn | ARN of SNS topic for alarm notifications | `string` | `""` | no |
| enable_code_deploy | Enable CodeDeploy for Blue/Green deployments | `bool` | `false` | no |
| instance_type | EC2 instance type for ECS cluster | `string` | `"t3.medium"` | no |
| mixed_instances_policy | Enable mixed instances policy for cost optimization | `bool` | `false` | no |
| on_demand_percentage | Percentage of on-demand instances when using mixed instances policy | `number` | `20` | no |
| spot_instance_types | List of instance types for spot instances | `list(string)` | `["t3.medium", "t3.large", "m5.large"]` | no |
| container_environment | Environment variables for the container | `list(object({name=string, value=string}))` | `[]` | no |
| container_secrets | Secrets for the container from Parameter Store or Secrets Manager | `list(object({name=string, valueFrom=string}))` | `[]` | no |
| health_check_path | Health check path for the target group | `string` | `"/"` | no |
| log_retention_days | CloudWatch log group retention period in days | `number` | `7` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

<details>
<summary>View all input variables</summary>

For a complete list of all input variables with detailed descriptions, see [variables.tf](./variables.tf).

</details>

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| cluster_name | Name of the ECS cluster |
| service_id | ID of the ECS service |
| service_name | Name of the ECS service |
| application_url | URL to access the application |
| alb_dns_name | DNS name of the Application Load Balancer |
| alb_arn | ARN of the Application Load Balancer |
| target_group_arn | ARN of the target group |
| ecs_security_group_id | ID of the ECS tasks security group |
| alb_security_group_id | ID of the ALB security group |
| ecs_execution_role_arn | ARN of the ECS task execution role |
| ecs_task_role_arn | ARN of the ECS task role |
| cloudwatch_log_group_name | Name of the CloudWatch log group |
| cloudwatch_dashboard_url | URL to the CloudWatch dashboard |
| autoscaling_group_name | Name of the Auto Scaling Group (EC2 only) |
| codedeploy_app_name | Name of the CodeDeploy application |
| log_insights_queries | Pre-configured CloudWatch Log Insights queries |

<details>
<summary>View all outputs</summary>

For a complete list of all outputs, see [outputs.tf](./outputs.tf).

</details>

## Examples

### 1. Simple Fargate Application
Perfect for development environments and simple applications.

```bash
cd examples/simple
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init && terraform apply
```

**Features:**
- Fargate launch type
- Basic auto-scaling
- Application Load Balancer
- CloudWatch monitoring

### 2. Complex Production Setup
Ideal for production workloads requiring high availability and cost optimization.

```bash
cd examples/complex  
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init && terraform apply
```

**Features:**
- EC2 launch type with Spot instances
- Mixed instances policy for cost optimization
- Blue/Green deployments with CodeDeploy
- Comprehensive monitoring and alerting
- SNS notifications
- Advanced auto-scaling policies

## Best Practices

### Security
- Always run ECS tasks in private subnets
- Use IAM roles instead of hardcoded credentials
- Store secrets in AWS Systems Manager Parameter Store or Secrets Manager
- Enable CloudTrail for API logging
- Use latest SSL policies for HTTPS

### Cost Optimization
- Use Spot instances for non-critical workloads
- Implement proper auto-scaling to avoid over-provisioning
- Right-size your tasks based on actual usage
- Use Reserved Instances for predictable workloads
- Monitor costs with AWS Cost Explorer

### Performance
- Place ALB in public subnets, ECS tasks in private subnets
- Use Application Load Balancer for HTTP/HTTPS traffic
- Configure appropriate health check intervals
- Monitor and tune auto-scaling policies
- Use Container Insights for detailed performance metrics

### High Availability
- Deploy across multiple Availability Zones
- Use at least 2 tasks for production workloads
- Configure proper health checks
- Set up monitoring and alerting
- Test disaster recovery procedures

## Monitoring and Troubleshooting

### CloudWatch Metrics
The module automatically creates alarms for:
- CPU utilization (ECS service and EC2 instances)
- Memory utilization  
- Target response time
- HTTP error rates
- Unhealthy target count

### Log Analysis
Use the provided Log Insights queries:
- Error log analysis
- Performance troubleshooting
- Memory usage patterns

### Common Issues

**Tasks not starting:**
- Check CloudWatch logs: `/aws/ecs/{service-name}`
- Verify IAM permissions
- Check security group rules
- Ensure container image is accessible

**Health check failures:**
- Verify health check path exists in your application
- Check container port configuration
- Review security group rules
- Monitor application startup time

**Auto-scaling issues:**
- Verify CloudWatch metrics are being published
- Check auto-scaling policies and thresholds
- Review cooldown periods
- Monitor target tracking metrics

## Upgrade Guide

### From v1.x to v2.x
- Review updated variable names and types
- Update your terraform.tfvars files
- Run `terraform plan` to review changes
- Apply incrementally for production workloads

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Update documentation
6. Submit a pull request

## Support

- 📖 [Documentation](./README.md)
- 💬 [Issues](./issues)
- 📧 [Contact](mailto:devops@company.com)

## License

This module is released under the [MIT License](./LICENSE).

---

## Changelog

### v2.0.0
- Added support for mixed instances policy
- Enhanced monitoring capabilities
- Improved security configurations
- Added CodeDeploy integration

### v1.0.0
- Initial release
- Basic ECS Fargate support
- ALB integration
- CloudWatch monitoring