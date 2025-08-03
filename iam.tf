# IAM Roles and Policies for ECS Fargate
# Security configuration following AWS least privilege principles

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  count = var.create_ecs_service ? 1 : 0
  name  = "${local.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-task-execution-role"
    Type = "iam-role"
  })
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count      = var.create_ecs_service ? 1 : 0
  role       = aws_iam_role.ecs_task_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Execution Role - Additional policy for ECS Exec
resource "aws_iam_role_policy" "ecs_task_execution_additional" {
  count = var.create_ecs_service && var.enable_execute_command ? 1 : 0
  name  = "${local.name_prefix}-ecs-task-execution-additional"
  role  = aws_iam_role.ecs_task_execution[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

# ECS Task Role (for application permissions)
resource "aws_iam_role" "ecs_task" {
  count = var.create_ecs_service && var.create_task_role ? 1 : 0
  name  = "${local.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-task-role"
    Type = "iam-role"
  })
}

# Attach custom policies to task role
resource "aws_iam_role_policy_attachment" "ecs_task_custom" {
  count      = var.create_ecs_service && var.create_task_role ? length(var.task_role_policy_arns) : 0
  role       = aws_iam_role.ecs_task[0].name
  policy_arn = var.task_role_policy_arns[count.index]
}

# Custom inline policy for task role
resource "aws_iam_role_policy" "ecs_task_custom" {
  count  = var.create_ecs_service && var.create_task_role && var.custom_task_role_policy != "" ? 1 : 0
  name   = "${local.name_prefix}-ecs-task-custom-policy"
  role   = aws_iam_role.ecs_task[0].id
  policy = var.custom_task_role_policy
}