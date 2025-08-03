# Networking Resources: ALB, Target Groups, and Security Groups
# All load balancing and network security configuration

# Security Group for ALB
resource "aws_security_group" "alb" {
  count       = local.create_alb_resources ? 1 : 0
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = local.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
    Type = "load-balancer"
  })
}

# ALB Security Group Rules - HTTP Ingress
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  count             = local.create_alb_resources ? 1 : 0
  security_group_id = aws_security_group.alb[0].id
  description       = "Allow HTTP traffic from specified CIDR blocks"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "alb-http-ingress"
  }
}

# ALB Security Group Rules - HTTPS Ingress  
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  count             = local.create_alb_resources ? 1 : 0
  security_group_id = aws_security_group.alb[0].id
  description       = "Allow HTTPS traffic from specified CIDR blocks"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "alb-https-ingress"
  }
}

# ALB Security Group Rules - Egress to ECS Tasks
resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  count             = local.create_alb_resources && var.create_ecs_service ? 1 : 0
  security_group_id = aws_security_group.alb[0].id
  description       = "Allow traffic to ECS tasks"

  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_tasks[0].id

  tags = {
    Name = "alb-to-ecs-egress"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  count       = var.create_ecs_service ? 1 : 0
  name        = "${local.name_prefix}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = local.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-tasks-sg"
    Type = "ecs-tasks"
  })
}

# ECS Tasks Security Group Rules - Ingress from ALB
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  count             = var.create_ecs_service && local.create_alb_resources ? 1 : 0
  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = "Allow traffic from ALB to container port"

  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb[0].id

  tags = {
    Name = "ecs-from-alb-ingress"
  }
}

# ECS Tasks Security Group Rules - Egress for HTTPS (443)
resource "aws_vpc_security_group_egress_rule" "ecs_https_egress" {
  count             = var.create_ecs_service ? 1 : 0
  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = "Allow HTTPS outbound traffic"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "ecs-https-egress"
  }
}

# ECS Tasks Security Group Rules - Egress for HTTP (80)
resource "aws_vpc_security_group_egress_rule" "ecs_http_egress" {
  count             = var.create_ecs_service ? 1 : 0
  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = "Allow HTTP outbound traffic"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "ecs-http-egress"
  }
}

# ECS Tasks Security Group Rules - Egress for DNS (53)
resource "aws_vpc_security_group_egress_rule" "ecs_dns_egress" {
  count             = var.create_ecs_service ? 1 : 0
  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = "Allow DNS outbound traffic"

  from_port   = 53
  to_port     = 53
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "ecs-dns-egress"
  }
}

# ECS Tasks Security Group Rules - Egress for NTP (123)
resource "aws_vpc_security_group_egress_rule" "ecs_ntp_egress" {
  count             = var.create_ecs_service ? 1 : 0
  security_group_id = aws_security_group.ecs_tasks[0].id
  description       = "Allow NTP outbound traffic"

  from_port   = 123
  to_port     = 123
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "ecs-ntp-egress"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  count              = local.create_alb_resources ? 1 : 0
  name               = "${local.name_prefix}-alb"
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = local.public_subnets

  enable_deletion_protection       = var.alb_enable_deletion_protection
  enable_cross_zone_load_balancing = var.alb_enable_cross_zone_load_balancing
  enable_http2                     = var.alb_enable_http2
  idle_timeout                     = var.alb_idle_timeout

  dynamic "access_logs" {
    for_each = var.enable_alb_access_logs ? [1] : []
    content {
      bucket  = var.alb_access_logs_bucket
      prefix  = var.alb_access_logs_prefix
      enabled = true
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
    Type = "application-load-balancer"
  })
}

# Target Group for ECS Service
resource "aws_lb_target_group" "main" {
  count       = local.create_alb_resources && var.create_ecs_service ? 1 : 0
  name        = "${local.name_prefix}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    enabled             = var.target_group_health_check_enabled
    healthy_threshold   = var.target_group_healthy_threshold
    unhealthy_threshold = var.target_group_unhealthy_threshold
    timeout             = var.target_group_health_check_timeout
    interval            = var.target_group_health_check_interval
    path                = var.target_group_health_check_path
    matcher             = var.target_group_matcher
    protocol            = "HTTP"
    port                = "traffic-port"
  }

  # Ensure target group is replaced before destroying
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tg"
    Type = "target-group"
  })
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http_redirect" {
  count             = local.create_alb_resources ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = local.common_tags
}

# HTTPS Listener with enhanced SSL configuration
resource "aws_lb_listener" "https" {
  count             = local.create_alb_resources ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.ssl_certificate_arn != "" ? var.ssl_certificate_arn : (var.create_ssl_certificate ? aws_acm_certificate_validation.main[0].certificate_arn : "")

  default_action {
    type             = "forward"
    target_group_arn = var.create_ecs_service ? aws_lb_target_group.main[0].arn : aws_lb_target_group.main[0].arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-https-listener"
    Type = "https-listener"
  })
}

# Additional SSL certificates for multi-domain support
resource "aws_lb_listener_certificate" "additional" {
  for_each        = var.additional_certificate_arns
  listener_arn    = aws_lb_listener.https[0].arn
  certificate_arn = each.value
}

# Advanced listener rules for sophisticated routing
resource "aws_lb_listener_rule" "host_based" {
  for_each     = var.host_based_routing_rules
  listener_arn = aws_lb_listener.https[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = each.value.target_group_arn
  }

  condition {
    host_header {
      values = each.value.host_patterns
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rule-${each.key}"
    Type = "listener-rule"
  })
}

resource "aws_lb_listener_rule" "path_based" {
  for_each     = var.path_based_routing_rules
  listener_arn = aws_lb_listener.https[0].arn
  priority     = each.value.priority

  action {
    type             = each.value.action_type
    target_group_arn = each.value.action_type == "forward" ? each.value.target_group_arn : null

    dynamic "redirect" {
      for_each = each.value.action_type == "redirect" ? [each.value.redirect_config] : []
      content {
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        status_code = redirect.value.status_code
        host        = redirect.value.host
        path        = redirect.value.path
        query       = redirect.value.query
      }
    }

    dynamic "fixed_response" {
      for_each = each.value.action_type == "fixed-response" ? [each.value.fixed_response_config] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-path-rule-${each.key}"
    Type = "listener-rule"
  })
}