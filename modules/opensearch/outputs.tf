# ============================================================================
# OUTPUTS FOR AMAZON OPENSEARCH MODULE
# ============================================================================

output "domain_endpoint" {
  description = "Domain-specific endpoint for the OpenSearch domain"
  value       = aws_opensearch_domain.main.endpoint
}

output "domain_arn" {
  description = "ARN of the OpenSearch domain"
  value       = aws_opensearch_domain.main.arn
}

output "domain_id" {
  description = "Unique identifier for the OpenSearch domain"
  value       = aws_opensearch_domain.main.domain_id
}

output "domain_name" {
  description = "Name of the OpenSearch domain"
  value       = aws_opensearch_domain.main.domain_name
}

output "kibana_endpoint" {
  description = "OpenSearch Dashboards endpoint"
  value       = aws_opensearch_domain.main.dashboard_endpoint
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.opensearch.id
}

output "engine_version" {
  description = "OpenSearch engine version"
  value       = aws_opensearch_domain.main.engine_version
}

output "vpc_options" {
  description = "VPC options for the domain"
  value = {
    vpc_id             = var.vpc_id
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.opensearch.id]
  }
}
