output "application_url" {
  description = "URL to access the application"
  value       = module.ecs_complex.application_url
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_complex.cluster_name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_complex.cluster_arn
}

output "service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_complex.service_name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.ecs_complex.alb_dns_name
}

output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch dashboard"
  value       = module.ecs_complex.cloudwatch_dashboard_url
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ecs_complex.autoscaling_group_name
}

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = module.ecs_complex.codedeploy_app_name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.ecs_complex.cloudwatch_log_group_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = aws_sns_topic.notifications.arn
}

output "log_insights_queries" {
  description = "Pre-configured CloudWatch Log Insights queries"
  value       = module.ecs_complex.log_insights_queries
}