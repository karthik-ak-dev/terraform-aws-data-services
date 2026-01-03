# ============================================================================
# OUTPUTS FOR AURORA POSTGRESQL SERVERLESS V2 MODULE
# ============================================================================

output "cluster_endpoint" {
  description = "Writer endpoint for the Aurora Serverless cluster"
  value       = aws_rds_cluster.aurora_serverless.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint for the Aurora Serverless cluster"
  value       = aws_rds_cluster.aurora_serverless.reader_endpoint
}

output "cluster_port" {
  description = "Port the cluster is listening on"
  value       = aws_rds_cluster.aurora_serverless.port
}

output "cluster_identifier" {
  description = "Identifier of the Aurora Serverless cluster"
  value       = aws_rds_cluster.aurora_serverless.cluster_identifier
}

output "cluster_arn" {
  description = "ARN of the Aurora Serverless cluster"
  value       = aws_rds_cluster.aurora_serverless.arn
}

output "cluster_resource_id" {
  description = "Resource ID of the Aurora Serverless cluster"
  value       = aws_rds_cluster.aurora_serverless.cluster_resource_id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.aurora_serverless.id
}

output "database_name" {
  description = "Name of the default database"
  value       = aws_rds_cluster.aurora_serverless.database_name
}

output "master_username" {
  description = "Master username"
  value       = aws_rds_cluster.aurora_serverless.master_username
}

output "scaling_configuration" {
  description = "Serverless scaling configuration"
  value = {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }
}
