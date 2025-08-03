# AWS Cloud Map Service Discovery
# Enables service-to-service communication within the VPC

# Service Discovery Service
resource "aws_service_discovery_service" "main" {
  count = var.enable_service_discovery ? 1 : 0
  name  = local.name_prefix

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = var.service_discovery_dns_ttl
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  # health_check_grace_period_seconds is not supported for service discovery

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-service-discovery"
    Type = "service-discovery"
  })
}