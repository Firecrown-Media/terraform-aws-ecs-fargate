# Data source for existing ALB
data "aws_lb" "existing" {
  count = var.existing_alb_arn != "" ? 1 : 0
  arn   = var.existing_alb_arn
}

# Data source for existing HTTPS listener (optional - may not exist)
data "aws_lb_listener" "existing_https" {
  count             = var.existing_alb_arn != "" && !var.create_https_listener ? 1 : 0
  load_balancer_arn = var.existing_alb_arn
  port              = 443
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  count       = var.create_alb ? 1 : 0
  name        = "${local.alb_name}-alb"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { name = "${local.alb_name}-alb" })

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic for health checks"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name                   = "${var.name}-ecs-tasks"
  description            = "Security group for ECS tasks"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = false
  tags                   = merge(local.common_tags, { name = "${var.name}-ecs-tasks" })

  # Dynamic ingress rule moved to separate resource to avoid circular dependency

  dynamic "ingress" {
    for_each = var.launch_type == "EC2" && !var.create_alb ? [1] : []
    content {
      description = "Container port for EC2 launch type"
      from_port   = var.container_port
      to_port     = var.container_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EFS egress rule moved to separate resource to avoid circular dependency
}

# Security Group for EC2 instances (when using EC2 launch type)
resource "aws_security_group" "ec2_instances" {
  count       = var.launch_type == "EC2" ? 1 : 0
  name        = "${var.name}-ec2-instances"
  description = "Security group for EC2 instances in ECS cluster"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { name = "${var.name}-ec2-instances" })

  # Ingress rule moved to separate resource to avoid circular dependency

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  count              = var.create_alb ? 1 : 0
  name               = local.alb_name
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = var.public_subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = local.common_tags
}

# Target Group (for both new and existing ALB)
resource "aws_lb_target_group" "main" {
  count       = var.create_alb || var.existing_alb_arn != "" ? 1 : 0
  name        = "${var.name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.launch_type == "FARGATE" ? "ip" : "instance"
  tags        = local.common_tags

  health_check {
    enabled             = true
    healthy_threshold   = var.healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.unhealthy_threshold
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.main]
}

# ALB Listener (HTTP)
resource "aws_lb_listener" "main" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = "80"
  protocol          = "HTTP"
  tags              = local.common_tags

  default_action {
    type = var.certificate_arn != "" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.certificate_arn == "" ? [1] : []
      content {
        target_group {
          arn = aws_lb_target_group.main[0].arn
        }
      }
    }
  }
}

# ALB Listener (HTTPS) - for new ALB
resource "aws_lb_listener" "https" {
  count             = var.create_alb && var.create_certificate ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = local.certificate_arn
  tags              = local.common_tags

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}

# HTTPS Listener for existing ALB
resource "aws_lb_listener" "existing_https" {
  count             = var.existing_alb_arn != "" && var.create_https_listener ? 1 : 0
  load_balancer_arn = var.existing_alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = local.certificate_arn
  tags              = local.common_tags

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Default response"
      status_code  = "404"
    }
  }
}

# Domain-based listener rule for existing ALB
resource "aws_lb_listener_rule" "domain_routing" {
  count        = var.existing_alb_arn != "" && var.domain_name != "" ? 1 : 0
  listener_arn = var.create_https_listener ? aws_lb_listener.existing_https[0].arn : data.aws_lb_listener.existing_https[0].arn
  priority     = var.listener_rule_priority
  tags         = local.common_tags

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }

  condition {
    host_header {
      values = [var.domain_name]
    }
  }
}

# ALB Listener Rules (if needed for advanced routing)
resource "aws_lb_listener_rule" "health_check" {
  count        = var.create_alb ? 1 : 0
  listener_arn = var.create_certificate ? aws_lb_listener.https[0].arn : aws_lb_listener.main[0].arn
  priority     = 100
  tags         = local.common_tags

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/health", "/healthcheck", "/health-check"]
    }
  }
}

# Separate security group rules to avoid circular dependencies

# ALB to ECS Tasks egress rule (for new ALB)
resource "aws_security_group_rule" "alb_to_ecs_tasks" {
  count                    = var.create_alb ? 1 : 0
  type                     = "egress"
  description              = "To ECS tasks"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks.id
  security_group_id        = aws_security_group.alb[0].id
}

# ECS Tasks from ALB ingress rule (for new ALB)
resource "aws_security_group_rule" "ecs_tasks_from_alb" {
  count                    = var.create_alb ? 1 : 0
  type                     = "ingress"
  description              = "From ALB"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb[0].id
  security_group_id        = aws_security_group.ecs_tasks.id
}

# ECS Tasks from existing ALB ingress rule
resource "aws_security_group_rule" "ecs_tasks_from_existing_alb" {
  count                    = var.existing_alb_arn != "" ? 1 : 0
  type                     = "ingress"
  description              = "From existing ALB"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = tolist(data.aws_lb.existing[0].security_groups)[0]
  security_group_id        = aws_security_group.ecs_tasks.id
}

# ECS Tasks to EFS egress rule
resource "aws_security_group_rule" "ecs_tasks_to_efs" {
  count                    = var.create_efs ? 1 : 0
  type                     = "egress"
  description              = "To EFS"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.efs[0].id
  security_group_id        = aws_security_group.ecs_tasks.id
}

# EC2 instances from ECS tasks ingress rule
resource "aws_security_group_rule" "ec2_instances_from_ecs_tasks" {
  count                    = var.launch_type == "EC2" ? 1 : 0
  type                     = "ingress"
  description              = "From ECS tasks"
  from_port                = 32768
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks.id
  security_group_id        = aws_security_group.ec2_instances[0].id
}