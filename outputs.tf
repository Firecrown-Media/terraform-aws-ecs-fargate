# ECS Cluster Outputs
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

# ECS Service Outputs
output "service_id" {
  description = "ID of the ECS service"
  value       = var.create_service ? aws_ecs_service.main[0].id : null
}

output "service_name" {
  description = "Name of the ECS service"
  value       = var.create_service ? aws_ecs_service.main[0].name : null
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = var.create_service ? aws_ecs_service.main[0].id : null
}

# Task Definition Outputs
output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = var.task_definition_arn != "" ? var.task_definition_arn : (var.create_service ? aws_ecs_task_definition.main[0].arn : null)
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = var.task_definition_arn != "" ? null : (var.create_service ? aws_ecs_task_definition.main[0].family : null)
}

# Load Balancer Outputs
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = var.create_alb ? aws_lb.main[0].arn : (var.existing_alb_arn != "" ? var.existing_alb_arn : null)
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = var.create_alb ? aws_lb.main[0].dns_name : (var.existing_alb_arn != "" ? data.aws_lb.existing[0].dns_name : null)
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = var.create_alb ? aws_lb.main[0].zone_id : (var.existing_alb_arn != "" ? data.aws_lb.existing[0].zone_id : null)
}

output "alb_hosted_zone_id" {
  description = "Hosted zone ID of the Application Load Balancer"
  value       = var.create_alb ? aws_lb.main[0].zone_id : (var.existing_alb_arn != "" ? data.aws_lb.existing[0].zone_id : null)
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = (var.create_alb || var.existing_alb_arn != "") ? aws_lb_target_group.main[0].arn : null
}

output "target_group_name" {
  description = "Name of the target group"
  value       = (var.create_alb || var.existing_alb_arn != "") ? aws_lb_target_group.main[0].name : null
}

# URL Output
output "application_url" {
  description = "URL to access the application"
  value = var.create_alb ? (local.certificate_arn != "" ? "https://${aws_lb.main[0].dns_name}" : "http://${aws_lb.main[0].dns_name}") : (
    var.existing_alb_arn != "" ? (var.domain_name != "" ? "https://${var.domain_name}" : "https://${data.aws_lb.existing[0].dns_name}") : null
  )
}

# Certificate Outputs
output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = local.certificate_arn
}

output "certificate_domain_name" {
  description = "Domain name of the SSL certificate"
  value       = var.create_certificate ? aws_acm_certificate.main[0].domain_name : var.certificate_domain_name
}

# Security Group Outputs
output "ecs_security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = var.create_alb ? aws_security_group.alb[0].id : null
}

output "ec2_security_group_id" {
  description = "ID of the EC2 instances security group"
  value       = var.launch_type == "EC2" ? aws_security_group.ec2_instances[0].id : null
}

# IAM Role Outputs
output "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_instance_role_arn" {
  description = "ARN of the ECS instance role (EC2 launch type only)"
  value       = var.launch_type == "EC2" ? aws_iam_role.ecs_instance_role[0].arn : null
}

# Auto Scaling Outputs
output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group (EC2 launch type only)"
  value       = var.launch_type == "EC2" ? aws_autoscaling_group.ecs[0].arn : null
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group (EC2 launch type only)"
  value       = var.launch_type == "EC2" ? aws_autoscaling_group.ecs[0].name : null
}

output "capacity_provider_name" {
  description = "Name of the ECS capacity provider (EC2 launch type only)"
  value       = var.launch_type == "EC2" ? aws_ecs_capacity_provider.main[0].name : null
}

# Monitoring Outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.arn
}

output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = var.enable_monitoring ? "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}" : null
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = var.enable_monitoring && var.enable_sns_notifications && var.sns_topic_arn == "" ? aws_sns_topic.alarms[0].arn : var.sns_topic_arn
}

# CodeDeploy Outputs
output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = var.enable_code_deploy && var.create_service ? aws_codedeploy_app.main[0].name : null
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = var.enable_code_deploy && var.create_service ? aws_codedeploy_deployment_group.main[0].deployment_group_name : null
}

# Log Insights Queries
output "log_insights_queries" {
  description = "Pre-configured CloudWatch Log Insights queries"
  value       = local.log_insights_queries
}

# Network Configuration
output "vpc_id" {
  description = "ID of the VPC"
  value       = var.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = var.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = var.public_subnets
}

# Container Configuration
output "container_port" {
  description = "Port the container exposes"
  value       = var.container_port
}

output "container_image" {
  description = "Docker image used for the container"
  value       = var.container_image
}

# EFS Outputs
output "efs_id" {
  description = "ID of the EFS filesystem"
  value       = var.create_efs ? aws_efs_file_system.main[0].id : null
}

output "efs_arn" {
  description = "ARN of the EFS filesystem"
  value       = var.create_efs ? aws_efs_file_system.main[0].arn : null
}

output "efs_dns_name" {
  description = "DNS name of the EFS filesystem"
  value       = var.create_efs ? aws_efs_file_system.main[0].dns_name : null
}

output "efs_mount_target_ids" {
  description = "List of EFS mount target IDs"
  value       = var.create_efs ? aws_efs_mount_target.main[*].id : []
}

output "efs_mount_target_dns_names" {
  description = "List of EFS mount target DNS names"
  value       = var.create_efs ? aws_efs_mount_target.main[*].dns_name : []
}

output "efs_access_point_ids" {
  description = "List of EFS access point IDs"
  value       = var.create_efs ? aws_efs_access_point.main[*].id : []
}

output "efs_access_point_arns" {
  description = "List of EFS access point ARNs"
  value       = var.create_efs ? aws_efs_access_point.main[*].arn : []
}

output "efs_security_group_id" {
  description = "ID of the EFS security group"
  value       = var.create_efs ? aws_security_group.efs[0].id : null
}