# Simple ECS Fargate Example

This example demonstrates a basic ECS Fargate deployment with minimal configuration. It creates:

- ECS Fargate cluster with a simple NGINX container
- Application Load Balancer with health checks
- Auto-scaling configuration
- Basic monitoring and logging

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- Existing VPC with public and private subnets
- Subnets tagged appropriately (see Data Sources section below)

## Data Sources

This example assumes you have an existing VPC with subnets tagged as follows:
- VPC tagged with `Name = "main-vpc"`
- Private subnets tagged with `Type = "private"`
- Public subnets tagged with `Type = "public"`

Modify the data source filters in `main.tf` to match your existing infrastructure.

## Usage

1. Copy the example terraform.tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   ```bash
   vim terraform.tfvars
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the plan:
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

5. Apply the configuration:
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

6. Access your application using the output URL:
   ```bash
   terraform output application_url
   ```

## Customization

To customize this example:

- Modify `container_image` to use your own Docker image
- Adjust `task_cpu` and `task_memory` based on your application needs
- Set `certificate_arn` to enable HTTPS
- Modify `health_check_path` to match your application's health endpoint

## Clean Up

To destroy the infrastructure:

```bash
terraform destroy -var-file="terraform.tfvars"
```

## Outputs

- `application_url` - URL to access your application
- `cluster_name` - Name of the ECS cluster
- `service_name` - Name of the ECS service