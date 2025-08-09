# ACM Certificate for HTTPS
resource "aws_acm_certificate" "main" {
  count             = var.create_certificate ? 1 : 0
  domain_name       = var.certificate_domain_name
  subject_alternative_names = var.certificate_subject_alternative_names
  validation_method = var.certificate_validation_method

  tags = merge(local.common_tags, {
    name = "${var.name}-certificate"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate validation (DNS method)
resource "aws_acm_certificate_validation" "main" {
  count           = var.create_certificate && var.certificate_validation_method == "DNS" ? 1 : 0
  certificate_arn = aws_acm_certificate.main[0].arn
  
  timeouts {
    create = "5m"
  }
}

# Local value to determine which certificate ARN to use
locals {
  certificate_arn = var.create_certificate ? aws_acm_certificate.main[0].arn : var.certificate_arn
}