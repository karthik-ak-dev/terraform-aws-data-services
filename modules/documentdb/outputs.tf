# ============================================================================
# OUTPUTS FOR AMAZON DOCUMENTDB MODULE
# ============================================================================

output "cluster_endpoint" {
  description = "Writer endpoint for the DocumentDB cluster"
  value       = aws_docdb_cluster.main.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint for the DocumentDB cluster"
  value       = aws_docdb_cluster.main.reader_endpoint
}

output "cluster_port" {
  description = "Port the cluster is listening on"
  value       = aws_docdb_cluster.main.port
}

output "cluster_identifier" {
  description = "Identifier of the DocumentDB cluster"
  value       = aws_docdb_cluster.main.cluster_identifier
}

output "cluster_arn" {
  description = "ARN of the DocumentDB cluster"
  value       = aws_docdb_cluster.main.arn
}

output "cluster_resource_id" {
  description = "Resource ID of the DocumentDB cluster"
  value       = aws_docdb_cluster.main.cluster_resource_id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.docdb.id
}

output "master_username" {
  description = "Master username"
  value       = aws_docdb_cluster.main.master_username
}

output "connection_string" {
  description = "MongoDB connection string format (without password)"
  value       = "mongodb://${aws_docdb_cluster.main.master_username}:<password>@${aws_docdb_cluster.main.endpoint}:${aws_docdb_cluster.main.port}/?tls=true&replicaSet=rs0&readPreference=secondaryPreferred"
}
