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
| load_balancer_container_name | Name of the container that the load balancer should target (defaults to service name) | `string` | `""` | no |
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
| enable_fargate_spot | Enable Fargate Spot instances for cost optimization | `bool` | `false` | no |
| fargate_spot_weight | Weight for Fargate Spot instances in capacity provider strategy (0-100) | `number` | `70` | no |
| fargate_base_capacity | Minimum number of tasks to run on regular Fargate (for availability) | `number` | `0` | no |
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
<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, < 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

## Modules

No modules.

## Resources

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_appautoscaling_policy.alb_request_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_autoscaling_group.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_dashboard.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.alb_5xx_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.alb_response_time](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.task_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.unhealthy_hosts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_codedeploy_app.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app) | resource |
| [aws_codedeploy_deployment_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group) | resource |
| [aws_ecs_capacity_provider.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_cluster_capacity_providers.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_efs_access_point.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_backup_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_file_system.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_instance_profile.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.codedeploy_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_autoscaling_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.events_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codedeploy_service_role_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_execution_role_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.events_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.codedeploy_service_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.existing_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.domain_routing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.health_check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ec2_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb_to_ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ec2_instances_from_ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_tasks_from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_tasks_from_existing_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_tasks_to_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.efs_from_ec2_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.efs_from_ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sns_topic.alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [terraform_data.account_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_lb.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_lb_listener.existing_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb_listener) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.ecs_optimized_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID for security validation | `string` | `null` | no |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Whether the ALB is internal | `bool` | `false` | no |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name of the ALB (defaults to var.name if not provided) | `string` | `null` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of SSL certificate for HTTPS listener | `string` | `null` | no |
| <a name="input_certificate_domain_name"></a> [certificate\_domain\_name](#input\_certificate\_domain\_name) | Domain name for the ACM certificate (e.g., *.trains.com) | `string` | `null` | no |
| <a name="input_certificate_subject_alternative_names"></a> [certificate\_subject\_alternative\_names](#input\_certificate\_subject\_alternative\_names) | Additional domain names for the certificate | `list(string)` | `[]` | no |
| <a name="input_certificate_validation_method"></a> [certificate\_validation\_method](#input\_certificate\_validation\_method) | Method to validate the certificate (DNS or EMAIL) | `string` | `"DNS"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster (defaults to var.name if not provided) | `string` | `null` | no |
| <a name="input_container_environment"></a> [container\_environment](#input\_container\_environment) | Environment variables for the container | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Docker image for the container | `string` | `"nginx:latest"` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port the container exposes | `number` | `80` | no |
| <a name="input_container_secrets"></a> [container\_secrets](#input\_container\_secrets) | Secrets for the container from Parameter Store or Secrets Manager | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cpu_alarm_threshold"></a> [cpu\_alarm\_threshold](#input\_cpu\_alarm\_threshold) | CPU utilization threshold for CloudWatch alarm | `number` | `80` | no |
| <a name="input_create_alb"></a> [create\_alb](#input\_create\_alb) | Whether to create an Application Load Balancer | `bool` | `true` | no |
| <a name="input_create_certificate"></a> [create\_certificate](#input\_create\_certificate) | Whether to create an ACM certificate for the domain | `bool` | `false` | no |
| <a name="input_create_efs"></a> [create\_efs](#input\_create\_efs) | Whether to create an EFS filesystem | `bool` | `false` | no |
| <a name="input_create_https_listener"></a> [create\_https\_listener](#input\_create\_https\_listener) | Whether to create HTTPS listener on existing ALB | `bool` | `false` | no |
| <a name="input_create_service"></a> [create\_service](#input\_create\_service) | Whether to create an ECS service | `bool` | `true` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Maximum percentage of tasks that can run during deployment | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Minimum percentage of healthy tasks during deployment | `number` | `100` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Desired number of EC2 instances in auto-scaling group | `number` | `2` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired number of tasks to run | `number` | `2` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name for listener rule (e.g., stage.trains.com) | `string` | `null` | no |
| <a name="input_efs_access_points"></a> [efs\_access\_points](#input\_efs\_access\_points) | List of EFS access points to create | <pre>list(object({<br/>    name = string<br/>    path = string<br/>    posix_user = optional(object({<br/>      gid            = number<br/>      uid            = number<br/>      secondary_gids = optional(list(number), [])<br/>    }))<br/>    creation_info = optional(object({<br/>      owner_gid   = number<br/>      owner_uid   = number<br/>      permissions = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_efs_backup_policy"></a> [efs\_backup\_policy](#input\_efs\_backup\_policy) | EFS backup policy (ENABLED or DISABLED) | `string` | `"ENABLED"` | no |
| <a name="input_efs_encrypted"></a> [efs\_encrypted](#input\_efs\_encrypted) | Whether to encrypt the EFS filesystem | `bool` | `true` | no |
| <a name="input_efs_kms_key_id"></a> [efs\_kms\_key\_id](#input\_efs\_kms\_key\_id) | The ARN for the KMS encryption key for EFS | `string` | `null` | no |
| <a name="input_efs_lifecycle_policy"></a> [efs\_lifecycle\_policy](#input\_efs\_lifecycle\_policy) | EFS lifecycle policy for transitioning files to IA storage class | `string` | `"AFTER_30_DAYS"` | no |
| <a name="input_efs_mount_points"></a> [efs\_mount\_points](#input\_efs\_mount\_points) | List of EFS mount points for container | <pre>list(object({<br/>    source_volume   = string<br/>    container_path  = string<br/>    read_only       = optional(bool, false)<br/>    access_point_id = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_efs_mount_targets_subnets"></a> [efs\_mount\_targets\_subnets](#input\_efs\_mount\_targets\_subnets) | List of subnet IDs for EFS mount targets (defaults to private\_subnets if not provided) | `list(string)` | `[]` | no |
| <a name="input_efs_name"></a> [efs\_name](#input\_efs\_name) | Name of the EFS filesystem (defaults to var.name if not provided) | `string` | `null` | no |
| <a name="input_efs_performance_mode"></a> [efs\_performance\_mode](#input\_efs\_performance\_mode) | The file system performance mode (generalPurpose or maxIO) | `string` | `"generalPurpose"` | no |
| <a name="input_efs_provisioned_throughput"></a> [efs\_provisioned\_throughput](#input\_efs\_provisioned\_throughput) | The throughput, measured in MiB/s, for provisioned throughput mode | `number` | `null` | no |
| <a name="input_efs_throughput_mode"></a> [efs\_throughput\_mode](#input\_efs\_throughput\_mode) | The file system throughput mode (bursting or provisioned) | `string` | `"bursting"` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Enable auto-scaling for ECS service | `bool` | `true` | no |
| <a name="input_enable_circuit_breaker"></a> [enable\_circuit\_breaker](#input\_enable\_circuit\_breaker) | Enable deployment circuit breaker | `bool` | `true` | no |
| <a name="input_enable_code_deploy"></a> [enable\_code\_deploy](#input\_enable\_code\_deploy) | Enable CodeDeploy for Blue/Green deployments | `bool` | `false` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Enable CloudWatch Container Insights for the cluster | `bool` | `true` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Enable deletion protection for the ALB | `bool` | `false` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Enable ECS execute command for debugging | `bool` | `false` | no |
| <a name="input_enable_fargate_spot"></a> [enable\_fargate\_spot](#input\_enable\_fargate\_spot) | Enable Fargate Spot instances for cost optimization | `bool` | `false` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable CloudWatch alarms and monitoring | `bool` | `true` | no |
| <a name="input_enable_rollback"></a> [enable\_rollback](#input\_enable\_rollback) | Enable automatic rollback on deployment failure | `bool` | `true` | no |
| <a name="input_enable_sns_notifications"></a> [enable\_sns\_notifications](#input\_enable\_sns\_notifications) | Enable SNS notifications for alarms | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_existing_alb_arn"></a> [existing\_alb\_arn](#input\_existing\_alb\_arn) | ARN of existing ALB to use instead of creating a new one | `string` | `null` | no |
| <a name="input_fargate_base_capacity"></a> [fargate\_base\_capacity](#input\_fargate\_base\_capacity) | Minimum number of tasks to run on regular Fargate (for availability) | `number` | `0` | no |
| <a name="input_fargate_spot_weight"></a> [fargate\_spot\_weight](#input\_fargate\_spot\_weight) | Weight for Fargate Spot instances in capacity provider strategy (0-100) | `number` | `70` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Force a new ECS service deployment. Required when changing capacity\_provider\_strategy on an existing service (AWS provider v6 constraint). | `bool` | `false` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Health check interval in seconds | `number` | `30` | no |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | HTTP status codes for successful health checks | `string` | `"200"` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Health check path for the target group | `string` | `"/"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Health check timeout in seconds | `number` | `5` | no |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | Number of consecutive successful health checks | `number` | `2` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for ECS cluster | `string` | `"t3.medium"` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Launch type for ECS service (FARGATE or EC2) | `string` | `"FARGATE"` | no |
| <a name="input_listener_rule_priority"></a> [listener\_rule\_priority](#input\_listener\_rule\_priority) | Priority for ALB listener rule | `number` | `100` | no |
| <a name="input_load_balancer_container_name"></a> [load\_balancer\_container\_name](#input\_load\_balancer\_container\_name) | Name of the container that the load balancer should target (defaults to service name) | `string` | `null` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Name of CloudWatch log group (defaults to /aws/ecs/{var.name}) | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log group retention period in days | `number` | `7` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Maximum capacity for auto-scaling | `number` | `10` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of EC2 instances in auto-scaling group | `number` | `10` | no |
| <a name="input_memory_alarm_threshold"></a> [memory\_alarm\_threshold](#input\_memory\_alarm\_threshold) | Memory utilization threshold for CloudWatch alarm | `number` | `80` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | Minimum capacity for auto-scaling | `number` | `1` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of EC2 instances in auto-scaling group | `number` | `1` | no |
| <a name="input_mixed_instances_policy"></a> [mixed\_instances\_policy](#input\_mixed\_instances\_policy) | Enable mixed instances policy for cost optimization | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources | `string` | n/a | yes |
| <a name="input_on_demand_percentage"></a> [on\_demand\_percentage](#input\_on\_demand\_percentage) | Percentage of on-demand instances when using mixed instances policy | `number` | `20` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet IDs for ECS tasks/instances | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnet IDs for ALB | `list(string)` | `[]` | no |
| <a name="input_scale_down_cooldown"></a> [scale\_down\_cooldown](#input\_scale\_down\_cooldown) | Cooldown period for scaling down (seconds) | `number` | `300` | no |
| <a name="input_scale_up_cooldown"></a> [scale\_up\_cooldown](#input\_scale\_up\_cooldown) | Cooldown period for scaling up (seconds) | `number` | `300` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the ECS service (defaults to var.name if not provided) | `string` | `null` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of SNS topic for alarm notifications | `string` | `null` | no |
| <a name="input_spot_instance_types"></a> [spot\_instance\_types](#input\_spot\_instance\_types) | List of instance types for spot instances | `list(string)` | <pre>[<br/>  "t3.medium",<br/>  "t3.large",<br/>  "m5.large"<br/>]</pre> | no |
| <a name="input_spot_price"></a> [spot\_price](#input\_spot\_price) | Spot price for EC2 instances (leave null for on-demand) | `string` | `null` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL security policy for HTTPS listener | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_target_cpu"></a> [target\_cpu](#input\_target\_cpu) | Target CPU utilization for auto-scaling | `number` | `70` | no |
| <a name="input_target_memory"></a> [target\_memory](#input\_target\_memory) | Target memory utilization for auto-scaling | `number` | `80` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | CPU units for the task (Fargate: 256, 512, 1024, 2048, 4096) | `number` | `256` | no |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | ARN of existing task definition to use (if not provided, a basic one will be created) | `string` | `null` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Memory for the task in MiB | `number` | `512` | no |
| <a name="input_termination_wait_time_in_minutes"></a> [termination\_wait\_time\_in\_minutes](#input\_termination\_wait\_time\_in\_minutes) | Time to wait before terminating original task set | `number` | `5` | no |
| <a name="input_unhealthy_threshold"></a> [unhealthy\_threshold](#input\_unhealthy\_threshold) | Number of consecutive failed health checks | `number` | `3` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where resources will be created | `string` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the Application Load Balancer |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the Application Load Balancer |
| <a name="output_alb_hosted_zone_id"></a> [alb\_hosted\_zone\_id](#output\_alb\_hosted\_zone\_id) | Hosted zone ID of the Application Load Balancer |
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | ID of the ALB security group |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | Zone ID of the Application Load Balancer |
| <a name="output_application_url"></a> [application\_url](#output\_application\_url) | URL to access the application |
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | ARN of the Auto Scaling Group (EC2 launch type only) |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | Name of the Auto Scaling Group (EC2 launch type only) |
| <a name="output_capacity_provider_name"></a> [capacity\_provider\_name](#output\_capacity\_provider\_name) | Name of the ECS capacity provider (EC2 launch type only) |
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | ARN of the SSL certificate |
| <a name="output_certificate_domain_name"></a> [certificate\_domain\_name](#output\_certificate\_domain\_name) | Domain name of the SSL certificate |
| <a name="output_cloudwatch_dashboard_url"></a> [cloudwatch\_dashboard\_url](#output\_cloudwatch\_dashboard\_url) | URL to the CloudWatch dashboard |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch log group |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch log group |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the ECS cluster |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of the ECS cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the ECS cluster |
| <a name="output_codedeploy_app_name"></a> [codedeploy\_app\_name](#output\_codedeploy\_app\_name) | Name of the CodeDeploy application |
| <a name="output_codedeploy_deployment_group_name"></a> [codedeploy\_deployment\_group\_name](#output\_codedeploy\_deployment\_group\_name) | Name of the CodeDeploy deployment group |
| <a name="output_container_image"></a> [container\_image](#output\_container\_image) | Docker image used for the container |
| <a name="output_container_port"></a> [container\_port](#output\_container\_port) | Port the container exposes |
| <a name="output_ec2_security_group_id"></a> [ec2\_security\_group\_id](#output\_ec2\_security\_group\_id) | ID of the EC2 instances security group |
| <a name="output_ecs_execution_role_arn"></a> [ecs\_execution\_role\_arn](#output\_ecs\_execution\_role\_arn) | ARN of the ECS task execution role |
| <a name="output_ecs_instance_role_arn"></a> [ecs\_instance\_role\_arn](#output\_ecs\_instance\_role\_arn) | ARN of the ECS instance role (EC2 launch type only) |
| <a name="output_ecs_security_group_id"></a> [ecs\_security\_group\_id](#output\_ecs\_security\_group\_id) | ID of the ECS tasks security group |
| <a name="output_ecs_task_role_arn"></a> [ecs\_task\_role\_arn](#output\_ecs\_task\_role\_arn) | ARN of the ECS task role |
| <a name="output_efs_access_point_arns"></a> [efs\_access\_point\_arns](#output\_efs\_access\_point\_arns) | List of EFS access point ARNs |
| <a name="output_efs_access_point_ids"></a> [efs\_access\_point\_ids](#output\_efs\_access\_point\_ids) | List of EFS access point IDs |
| <a name="output_efs_arn"></a> [efs\_arn](#output\_efs\_arn) | ARN of the EFS filesystem |
| <a name="output_efs_dns_name"></a> [efs\_dns\_name](#output\_efs\_dns\_name) | DNS name of the EFS filesystem |
| <a name="output_efs_id"></a> [efs\_id](#output\_efs\_id) | ID of the EFS filesystem |
| <a name="output_efs_mount_target_dns_names"></a> [efs\_mount\_target\_dns\_names](#output\_efs\_mount\_target\_dns\_names) | List of EFS mount target DNS names |
| <a name="output_efs_mount_target_ids"></a> [efs\_mount\_target\_ids](#output\_efs\_mount\_target\_ids) | List of EFS mount target IDs |
| <a name="output_efs_security_group_id"></a> [efs\_security\_group\_id](#output\_efs\_security\_group\_id) | ID of the EFS security group |
| <a name="output_log_insights_queries"></a> [log\_insights\_queries](#output\_log\_insights\_queries) | Pre-configured CloudWatch Log Insights queries |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of private subnet IDs |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of public subnet IDs |
| <a name="output_service_arn"></a> [service\_arn](#output\_service\_arn) | ARN of the ECS service |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | ID of the ECS service |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of the ECS service |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of the SNS topic for alarms |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the target group |
| <a name="output_target_group_name"></a> [target\_group\_name](#output\_target\_group\_name) | Name of the target group |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ARN of the task definition |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | Family of the task definition |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
<!-- END_TF_DOCS -->