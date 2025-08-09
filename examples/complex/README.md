# Complex ECS Example with EC2, Spot Instances, and Full Observability

This example demonstrates an advanced ECS deployment with comprehensive features including:

- **ECS EC2 cluster** with mixed instances policy (On-Demand + Spot)
- **Cost optimization** through Spot instances and auto-scaling
- **Blue/Green deployments** with AWS CodeDeploy
- **Comprehensive monitoring** with CloudWatch alarms and dashboards
- **SNS notifications** for alerts and events
- **Advanced networking** with Application Load Balancer
- **Security best practices** with proper IAM roles and security groups

## Architecture Features

### Cost Optimization
- Mixed instances policy combining On-Demand and Spot instances
- Multiple instance types for better Spot availability
- ECS-managed auto-scaling for both EC2 instances and tasks

### High Availability
- Multi-AZ deployment across private subnets
- Application Load Balancer with health checks
- Auto-scaling based on CPU, memory, and request count

### Observability
- CloudWatch Container Insights enabled
- Comprehensive alarms for CPU, memory, response time, and errors
- Custom CloudWatch dashboard
- SNS notifications for all alerts
- CloudWatch Events for ECS task state changes
- Log Insights queries for troubleshooting

### Security
- Tasks run in private subnets only
- Least-privilege IAM roles
- Security groups with minimal required access
- Support for secrets management via Parameter Store/Secrets Manager

### Deployment
- Blue/Green deployments with CodeDeploy
- Rolling updates with configurable health checks
- Circuit breaker and automatic rollback on failures

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- Existing VPC with public and private subnets
- Subnets tagged appropriately (see Configuration section)
- SSL certificate in AWS Certificate Manager (optional)
- Email address for notifications

## Configuration

### VPC and Subnets
Update the data sources in `main.tf` to match your existing infrastructure:
- VPC tagged with `name = "main-vpc"` (or update `vpc_name` variable)
- Private subnets tagged with `type = "private"`
- Public subnets tagged with `type = "public"`

### Secrets Management
If using secrets, ensure they exist in AWS Systems Manager Parameter Store or AWS Secrets Manager before deployment.

## Usage

1. **Copy and configure variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   vim terraform.tfvars
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review the plan:**
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

5. **Confirm SNS subscription:** Check your email and confirm the SNS subscription for notifications.

6. **Access your application:**
   ```bash
   terraform output application_url
   ```

## Monitoring and Troubleshooting

### CloudWatch Dashboard
Access the pre-configured dashboard:
```bash
terraform output cloudwatch_dashboard_url
```

### Log Insights Queries
Use the pre-configured queries for troubleshooting:
```bash
terraform output log_insights_queries
```

Example queries included:
- Error log analysis
- Slow request identification  
- Memory usage patterns

### Key Metrics to Monitor
- **ECS Service**: CPU/Memory utilization, task counts
- **Auto Scaling Group**: Instance counts, health status
- **Application Load Balancer**: Response times, error rates, healthy targets
- **Custom Alarms**: Disk utilization, task state changes

## CodeDeploy Blue/Green Deployments

When `enable_code_deploy = true`, the module creates:
- CodeDeploy application and deployment group
- Blue/Green deployment configuration
- Automatic rollback on deployment failures

To deploy new versions:
1. Update your task definition with a new image
2. Use CodeDeploy to orchestrate the Blue/Green deployment
3. Monitor the deployment through CloudWatch and ALB target groups

## Cost Optimization Tips

1. **Spot Instance Configuration:**
   - Adjust `on_demand_percentage` based on your availability requirements
   - Use diverse `spot_instance_types` for better Spot availability
   - Monitor Spot interruption rates and adjust as needed

2. **Auto Scaling:**
   - Fine-tune CPU/memory thresholds based on your application patterns
   - Adjust cooldown periods to prevent excessive scaling
   - Use predictive scaling for known traffic patterns

3. **Right-sizing:**
   - Monitor actual CPU/memory usage and adjust task definitions
   - Use CloudWatch Container Insights for detailed resource analysis

## Security Considerations

- Tasks run in private subnets with no direct internet access
- All secrets managed through AWS services (Parameter Store/Secrets Manager)
- IAM roles follow least-privilege principles
- Security groups restrict access to required ports only
- ALB handles SSL termination with modern security policies

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy -var-file="terraform.tfvars"
```

**Note:** Ensure you don't have any running tasks or deployments before destroying.

## Customization

### Adding Custom Alarms
Add custom CloudWatch alarms by extending the monitoring configuration in `main.tf`.

### Custom Health Checks
Modify `health_check_path` and related parameters to match your application's health endpoint.

### Advanced Routing
The ALB supports advanced routing rules. Extend the networking configuration for complex routing scenarios.

### Additional Auto Scaling Metrics
Add custom auto-scaling policies based on application-specific metrics.