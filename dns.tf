# DNS and SSL Certificate Management
# Provides complete domain management for ECS Fargate applications

# ACM Certificate for the application domain
resource "aws_acm_certificate" "main" {
  count = var.create_ssl_certificate ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.certificate_validation_method

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ssl-certificate"
    Type = "ssl-certificate"
  })
}

# Route53 DNS validation records for certificate
resource "aws_route53_record" "certificate_validation" {
  for_each = var.create_ssl_certificate && var.certificate_validation_method == "DNS" ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id

  # Route53 records don't support tags
}

# Certificate validation
resource "aws_acm_certificate_validation" "main" {
  count = var.create_ssl_certificate && var.certificate_validation_method == "DNS" ? 1 : 0

  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}

# Main DNS record pointing to ALB
resource "aws_route53_record" "main" {
  count   = var.create_dns_record && local.create_alb_resources ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.dns_record_name != "" ? var.dns_record_name : var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.main[0].dns_name
    zone_id                = aws_lb.main[0].zone_id
    evaluate_target_health = true
  }

  # Route53 records don't support tags
}

# Additional DNS records can be added manually if needed

# Route53 Health Check for the application
resource "aws_route53_health_check" "main" {
  count             = var.create_route53_health_check ? 1 : 0
  fqdn              = var.domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = var.health_check_resource_path
  failure_threshold = var.health_check_failure_threshold
  request_interval  = var.health_check_request_interval
  # CloudWatch logging not needed for basic health check
  insufficient_data_health_status = "Unhealthy"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-health-check"
    Type = "health-check"
  })
}

# DNS and SSL variables are now defined in variables.tf