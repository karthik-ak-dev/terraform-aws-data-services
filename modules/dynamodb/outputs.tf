# ============================================================================
# OUTPUTS FOR DYNAMODB MODULE
# ============================================================================

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.main.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.main.id
}

output "hash_key" {
  description = "Hash key of the table"
  value       = aws_dynamodb_table.main.hash_key
}

output "range_key" {
  description = "Range key of the table"
  value       = aws_dynamodb_table.main.range_key
}

output "stream_arn" {
  description = "ARN of the DynamoDB Stream (if enabled)"
  value       = var.stream_enabled ? aws_dynamodb_table.main.stream_arn : null
}

output "stream_label" {
  description = "Timestamp of the DynamoDB Stream (if enabled)"
  value       = var.stream_enabled ? aws_dynamodb_table.main.stream_label : null
}

output "billing_mode" {
  description = "Billing mode of the table"
  value       = aws_dynamodb_table.main.billing_mode
}

output "global_secondary_index_names" {
  description = "Names of Global Secondary Indexes"
  value       = [for gsi in var.global_secondary_indexes : gsi.name]
}
