# TFLint Configuration for AWS ECS Fargate Module
# https://github.com/terraform-linters/tflint

config {
  # Enable module inspection
  module = true
  
  # Force exit on issues
  force = false
  
  # Disable color output for CI
  color = false
}

# AWS Plugin Configuration
plugin "aws" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Terraform Best Practices Plugin
plugin "terraform" {
  enabled = true
  version = "0.5.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

# Rule Configuration
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_standard_module_structure" {
  enabled = true
}

# AWS-specific rules
rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_instance_previous_type" {
  enabled = true
}

rule "aws_resource_missing_tags" {
  enabled = true
  tags = ["Environment", "ManagedBy"]
}

rule "aws_s3_bucket_invalid_acl" {
  enabled = true
}

rule "aws_s3_bucket_invalid_policy" {
  enabled = true
}

rule "aws_security_group_rule_invalid_protocol" {
  enabled = true
}

rule "aws_iam_policy_invalid_policy" {
  enabled = true
}

rule "aws_ecs_task_definition_invalid_cpu_memory" {
  enabled = true
}

rule "aws_lb_invalid_load_balancer_type" {
  enabled = true
}

rule "aws_cloudwatch_log_group_invalid_retention_in_days" {
  enabled = true
}