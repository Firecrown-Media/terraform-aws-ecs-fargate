# terraform-aws-ecs-fargate Module Outputs
# Comprehensive outputs following Terraform best practices

#------------------------------------------------------------------------------
# ECS Outputs
#------------------------------------------------------------------------------

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = var.create_ecs_cluster ? aws_ecs_cluster.main[0].id : null
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = var.create_ecs_cluster ? aws_ecs_cluster.main[0].arn : null
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = var.create_ecs_cluster ? aws_ecs_cluster.main[0].name : null
}

output "ecs_service_id" {
  description = "ID of the ECS service"
  value       = var.create_ecs_service ? aws_ecs_service.main[0].id : null
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = var.create_ecs_service ? aws_ecs_service.main[0].name : null
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = var.create_ecs_service ? aws_ecs_service.main[0].id : null
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = var.create_ecs_service ? aws_ecs_task_definition.main[0].arn : null
}

output "ecs_task_definition_family" {
  description = "Family of the ECS task definition"
  value       = var.create_ecs_service ? aws_ecs_task_definition.main[0].family : null
}

output "ecs_task_definition_revision" {
  description = "Revision of the ECS task definition"
  value       = var.create_ecs_service ? aws_ecs_task_definition.main[0].revision : null
}

#------------------------------------------------------------------------------
# Load Balancer Outputs
#------------------------------------------------------------------------------

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = local.create_alb_resources ? aws_lb.main[0].id : null
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = local.create_alb_resources ? aws_lb.main[0].arn : null
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = local.create_alb_resources ? aws_lb.main[0].dns_name : null
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer"
  value       = local.create_alb_resources ? aws_lb.main[0].zone_id : null
}

output "alb_hosted_zone_id" {
  description = "Hosted zone ID of the Application Load Balancer (alias for alb_zone_id)"
  value       = local.create_alb_resources ? aws_lb.main[0].zone_id : null
}

output "target_group_id" {
  description = "ID of the target group"
  value       = local.create_alb_resources && var.create_ecs_service ? aws_lb_target_group.main[0].id : null
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = local.create_alb_resources && var.create_ecs_service ? aws_lb_target_group.main[0].arn : null
}

output "target_group_name" {
  description = "Name of the target group"
  value       = local.create_alb_resources && var.create_ecs_service ? aws_lb_target_group.main[0].name : null
}

output "listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = local.create_alb_resources ? aws_lb_listener.https[0].arn : null
}

#------------------------------------------------------------------------------
# Security Group Outputs
#------------------------------------------------------------------------------

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = local.create_alb_resources ? aws_security_group.alb[0].id : null
}

output "alb_security_group_arn" {
  description = "ARN of the ALB security group"
  value       = local.create_alb_resources ? aws_security_group.alb[0].arn : null
}

output "ecs_security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = var.create_ecs_service ? aws_security_group.ecs_tasks[0].id : null
}

output "ecs_security_group_arn" {
  description = "ARN of the ECS tasks security group"
  value       = var.create_ecs_service ? aws_security_group.ecs_tasks[0].arn : null
}

#------------------------------------------------------------------------------
# IAM Role Outputs
#------------------------------------------------------------------------------

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = var.create_ecs_service ? aws_iam_role.ecs_task_execution[0].arn : null
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = var.create_ecs_service ? aws_iam_role.ecs_task_execution[0].name : null
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = var.create_ecs_service && var.create_task_role ? aws_iam_role.ecs_task[0].arn : null
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role"
  value       = var.create_ecs_service && var.create_task_role ? aws_iam_role.ecs_task[0].name : null
}

#------------------------------------------------------------------------------
# CloudWatch Outputs
#------------------------------------------------------------------------------

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.create_ecs_service ? aws_cloudwatch_log_group.main[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = var.create_ecs_service ? aws_cloudwatch_log_group.main[0].arn : null
}

output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value = var.create_ecs_service && var.enable_monitoring && var.create_dashboard ? (
    "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.id}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}"
  ) : null
}

#------------------------------------------------------------------------------
# Auto Scaling Outputs
#------------------------------------------------------------------------------

output "autoscaling_target_resource_id" {
  description = "Resource ID of the autoscaling target"
  value       = var.create_ecs_service && var.enable_auto_scaling ? aws_appautoscaling_target.ecs_target[0].resource_id : null
}

output "autoscaling_cpu_policy_arn" {
  description = "ARN of the CPU autoscaling policy"
  value       = var.create_ecs_service && var.enable_auto_scaling ? aws_appautoscaling_policy.ecs_cpu_policy[0].arn : null
}

output "autoscaling_memory_policy_arn" {
  description = "ARN of the memory autoscaling policy"
  value       = var.create_ecs_service && var.enable_auto_scaling ? aws_appautoscaling_policy.ecs_memory_policy[0].arn : null
}

#------------------------------------------------------------------------------
# Service Discovery Outputs
#------------------------------------------------------------------------------

output "service_discovery_service_id" {
  description = "ID of the service discovery service"
  value       = var.enable_service_discovery ? aws_service_discovery_service.main[0].id : null
}

output "service_discovery_service_arn" {
  description = "ARN of the service discovery service"
  value       = var.enable_service_discovery ? aws_service_discovery_service.main[0].arn : null
}

output "service_discovery_service_name" {
  description = "Name of the service discovery service"
  value       = var.enable_service_discovery ? aws_service_discovery_service.main[0].name : null
}

#------------------------------------------------------------------------------
# Monitoring Outputs
#------------------------------------------------------------------------------

output "cpu_alarm_id" {
  description = "ID of the CPU utilization alarm"
  value       = var.create_ecs_service && var.enable_monitoring ? aws_cloudwatch_metric_alarm.ecs_cpu_high[0].id : null
}

output "memory_alarm_id" {
  description = "ID of the memory utilization alarm"
  value       = var.create_ecs_service && var.enable_monitoring ? aws_cloudwatch_metric_alarm.ecs_memory_high[0].id : null
}

output "service_count_alarm_id" {
  description = "ID of the service count alarm"
  value       = var.create_ecs_service && var.enable_monitoring ? aws_cloudwatch_metric_alarm.ecs_service_count[0].id : null
}

#------------------------------------------------------------------------------
# Computed Values
#------------------------------------------------------------------------------

output "container_image" {
  description = "Container image being used"
  value       = var.container_image
}

output "container_port" {
  description = "Container port being used"
  value       = var.container_port
}

output "region" {
  description = "AWS region where resources are deployed"
  value       = data.aws_region.current.id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = data.aws_availability_zones.available.names
}

#------------------------------------------------------------------------------
# Storage Outputs
#------------------------------------------------------------------------------

output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = var.enable_efs ? aws_efs_file_system.main[0].id : null
}

output "efs_file_system_arn" {
  description = "ARN of the EFS file system"
  value       = var.enable_efs ? aws_efs_file_system.main[0].arn : null
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = var.enable_efs ? aws_efs_file_system.main[0].dns_name : null
}

output "efs_access_point_ids" {
  description = "IDs of the EFS access points"
  value       = var.enable_efs ? { for k, v in aws_efs_access_point.main : k => v.id } : {}
}

output "efs_access_point_arns" {
  description = "ARNs of the EFS access points"
  value       = var.enable_efs ? { for k, v in aws_efs_access_point.main : k => v.arn } : {}
}

output "efs_security_group_id" {
  description = "ID of the EFS security group"
  value       = var.enable_efs ? aws_security_group.efs[0].id : null
}

output "efs_kms_key_id" {
  description = "ID of the EFS KMS key"
  value       = var.enable_efs && var.create_efs_kms_key ? aws_kms_key.efs[0].id : null
}

output "efs_kms_key_arn" {
  description = "ARN of the EFS KMS key"
  value       = var.enable_efs && var.create_efs_kms_key ? aws_kms_key.efs[0].arn : null
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.app_data[0].id : null
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.app_data[0].arn : null
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.app_data[0].bucket_domain_name : null
}

#------------------------------------------------------------------------------
# DNS and SSL Outputs
#------------------------------------------------------------------------------

output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = var.create_ssl_certificate ? aws_acm_certificate_validation.main[0].certificate_arn : null
}

output "ssl_certificate_domain_validation_options" {
  description = "Domain validation options for the SSL certificate"
  value       = var.create_ssl_certificate ? aws_acm_certificate.main[0].domain_validation_options : null
  sensitive   = true
}

output "route53_record_name" {
  description = "Name of the Route53 DNS record"
  value       = var.create_dns_record && local.create_alb_resources ? aws_route53_record.main[0].name : null
}

output "route53_record_fqdn" {
  description = "FQDN of the Route53 DNS record"
  value       = var.create_dns_record && local.create_alb_resources ? aws_route53_record.main[0].fqdn : null
}

output "route53_health_check_id" {
  description = "ID of the Route53 health check"
  value       = var.create_route53_health_check ? aws_route53_health_check.main[0].id : null
}

#------------------------------------------------------------------------------
# Spot Instance Configuration
#------------------------------------------------------------------------------

output "spot_instances_enabled" {
  description = "Whether spot instances are enabled"
  value       = var.enable_spot_instances
}

output "capacity_provider_strategy" {
  description = "ECS capacity provider strategy configuration"
  value = var.enable_spot_instances ? {
    spot_weight      = var.spot_instance_weight
    spot_base        = var.spot_instance_base
    on_demand_weight = var.on_demand_weight
    on_demand_base   = var.on_demand_base
  } : null
}

#------------------------------------------------------------------------------
# URL and Connection Information
#------------------------------------------------------------------------------

output "application_url" {
  description = "URL to access the application (ALB DNS name with HTTPS)"
  value       = local.create_alb_resources ? "https://${aws_lb.main[0].dns_name}" : null
}

output "health_check_url" {
  description = "URL for health check endpoint"
  value       = local.create_alb_resources ? "https://${aws_lb.main[0].dns_name}${var.target_group_health_check_path}" : null
}

output "custom_domain_url" {
  description = "URL using custom domain (if DNS record is created)"
  value       = var.create_dns_record && var.domain_name != "" ? "https://${var.domain_name}" : null
}