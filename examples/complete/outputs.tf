# ============================================================================
# OUTPUTS FOR COMPLETE EXAMPLE
# ============================================================================

# Aurora PostgreSQL
output "aurora_cluster_endpoint" {
  description = "Aurora PostgreSQL writer endpoint"
  value       = module.aurora_postgres.cluster_endpoint
}

output "aurora_reader_endpoint" {
  description = "Aurora PostgreSQL reader endpoint"
  value       = module.aurora_postgres.reader_endpoint
}

# Aurora Serverless
output "aurora_serverless_endpoint" {
  description = "Aurora Serverless endpoint"
  value       = module.aurora_serverless.cluster_endpoint
}

# Redis
output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = module.redis.primary_endpoint
}

# Valkey
output "valkey_endpoint" {
  description = "Valkey Serverless endpoint"
  value       = module.valkey.endpoint
}

# DynamoDB
output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = module.dynamodb.table_arn
}

# DocumentDB
output "documentdb_endpoint" {
  description = "DocumentDB cluster endpoint"
  value       = module.documentdb.cluster_endpoint
}

# OpenSearch
output "opensearch_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = module.opensearch.domain_endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "OpenSearch Dashboards endpoint"
  value       = module.opensearch.kibana_endpoint
}

# S3
output "data_bucket_name" {
  description = "S3 data bucket name"
  value       = module.data_bucket.bucket_name
}

output "data_bucket_arn" {
  description = "S3 data bucket ARN"
  value       = module.data_bucket.bucket_arn
}
