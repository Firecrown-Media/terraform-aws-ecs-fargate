# Adopting an existing CodeDeploy blue/green service that runs on a shared ECS
# cluster behind a shared ALB -- the shape the module could not express before
# v1.1.0. Nothing here creates a cluster, an ALB, or a target group.

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "adopted_service" {
  source = "../.."

  name        = "kserv-prod-api"
  environment = "prod"

  # Shared cluster owned elsewhere: the module places the service in it but
  # never manages its settings, capacity providers, or tags.
  create_cluster       = false
  existing_cluster_arn = "arn:aws:ecs:us-east-1:378073025324:cluster/kserv-prod"

  # CodeDeploy owns rollouts; the pipeline registers task-definition revisions.
  deployment_controller_type = "CODE_DEPLOY"
  task_definition_arn        = "arn:aws:ecs:us-east-1:378073025324:task-definition/kserv-prod-api:1"

  # Shared ALB, and an existing blue/green target-group pair. The module
  # attaches to the blue group; CodeDeploy swaps between the two.
  create_alb                = false
  existing_alb_arn          = "arn:aws:elasticloadbalancing:us-east-1:378073025324:loadbalancer/app/kserv-prod/d6ffe264fcc2f330"
  existing_target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:378073025324:targetgroup/kserv-prod-api-tg-blue/f45ddba6b360a490"
  create_https_listener     = false

  vpc_id          = "vpc-001aa53043098c2e1"
  private_subnets = ["subnet-0120655c88130ed89"]
  container_port  = 3500

  # Names that predate the module and must not be recreated under new ones.
  ecs_tasks_security_group_name = "kserv-prod-api-sg-task"

  desired_count      = 10
  enable_autoscaling = false
  enable_monitoring  = false
}
