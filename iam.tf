# ECS Task Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.name}-ecs-execution-role"
  tags = local.common_tags

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
}

# ECS Task Execution Role Policy Attachment
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy for accessing Parameter Store and Secrets Manager
resource "aws_iam_role_policy" "ecs_execution_role_additional" {
  name = "${var.name}-ecs-execution-additional"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = "${aws_cloudwatch_log_group.main.arn}:*"
      }
    ]
  })
}

# ECS Task Role (for application permissions)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecs-task-role"
  tags = local.common_tags

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
}

# ECS Task Role Policy (basic permissions for application)
resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name = "${var.name}-ecs-task-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.main.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}

# EC2 Instance Profile (for EC2 launch type)
resource "aws_iam_instance_profile" "ecs" {
  count = var.launch_type == "EC2" ? 1 : 0
  name  = "${var.name}-ecs-instance-profile"
  role  = aws_iam_role.ecs_instance_role[0].name
  tags  = local.common_tags
}

# EC2 Instance Role (for EC2 launch type)
resource "aws_iam_role" "ecs_instance_role" {
  count = var.launch_type == "EC2" ? 1 : 0
  name  = "${var.name}-ecs-instance-role"
  tags  = local.common_tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# EC2 Instance Role Policy Attachments
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  count      = var.launch_type == "EC2" ? 1 : 0
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ssm_policy" {
  count      = var.launch_type == "EC2" ? 1 : 0
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_cloudwatch_policy" {
  count      = var.launch_type == "EC2" ? 1 : 0
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Auto Scaling Role (for ECS service auto scaling)
resource "aws_iam_role" "ecs_autoscaling_role" {
  count = var.create_service && var.enable_autoscaling ? 1 : 0
  name  = "${var.name}-ecs-autoscaling-role"
  tags  = local.common_tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      }
    ]
  })
}

# Auto Scaling Role Policy Attachment - Updated to use current managed policy
resource "aws_iam_role_policy_attachment" "ecs_autoscaling_role_policy" {
  count      = var.create_service && var.enable_autoscaling ? 1 : 0
  role       = aws_iam_role.ecs_autoscaling_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSServiceRoleForApplicationAutoScaling"
}

# CodeDeploy Service Role (for Blue/Green deployments)
resource "aws_iam_role" "codedeploy_service_role" {
  count = var.enable_code_deploy && var.create_service ? 1 : 0
  name  = "${var.name}-codedeploy-service-role"
  tags  = local.common_tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

# CodeDeploy Service Role Policy Attachment
resource "aws_iam_role_policy_attachment" "codedeploy_service_role_policy" {
  count      = var.enable_code_deploy && var.create_service ? 1 : 0
  role       = aws_iam_role.codedeploy_service_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForECS"
}

# Additional CodeDeploy permissions for ECS
resource "aws_iam_role_policy" "codedeploy_service_role_additional" {
  count = var.enable_code_deploy && var.create_service ? 1 : 0
  name  = "${var.name}-codedeploy-additional"
  role  = aws_iam_role.codedeploy_service_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:CreateTaskSet",
          "ecs:DeleteTaskSet",
          "ecs:DescribeServices",
          "ecs:UpdateServicePrimaryTaskSet",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyRule",
          "lambda:InvokeFunction",
          "cloudwatch:DescribeAlarms",
          "sns:Publish",
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      }
    ]
  })
}

# CloudWatch Events Role (for scheduled tasks, if needed)
resource "aws_iam_role" "events_role" {
  count = var.create_service ? 1 : 0
  name  = "${var.name}-events-role"
  tags  = local.common_tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Events Role Policy
resource "aws_iam_role_policy" "events_role_policy" {
  count = var.create_service ? 1 : 0
  name  = "${var.name}-events-policy"
  role  = aws_iam_role.events_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask"
        ]
        Resource = [
          var.task_definition_arn != "" ? var.task_definition_arn : aws_ecs_task_definition.main[0].arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      }
    ]
  })
}