# ============================================================================
# OUTPUTS FOR VALKEY SERVERLESS MODULE
# ============================================================================

output "endpoint" {
  description = "Endpoint for the Valkey Serverless cluster"
  value       = aws_elasticache_serverless_cache.valkey.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint for the Valkey Serverless cluster"
  value       = aws_elasticache_serverless_cache.valkey.reader_endpoint
}

output "arn" {
  description = "ARN of the Valkey Serverless cluster"
  value       = aws_elasticache_serverless_cache.valkey.arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.valkey.id
}

output "user_group_id" {
  description = "ID of the user group"
  value       = aws_elasticache_user_group.valkey.user_group_id
}

output "port" {
  description = "Port for Valkey connections"
  value       = 6379
}

output "scaling_limits" {
  description = "Configured scaling limits"
  value = {
    max_data_storage_gb = var.max_data_storage_gb
    max_ecpu_per_second = var.max_ecpu_per_second
  }
}
