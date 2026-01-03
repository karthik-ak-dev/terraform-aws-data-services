# ============================================================================
# VARIABLES FOR ELASTICACHE REDIS MODULE
# ============================================================================

# ============================================================================
# REQUIRED VARIABLES
# ============================================================================

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC for security group rules"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Redis cluster"
  type        = list(string)
}

variable "auth_token" {
  description = "Auth token for Redis authentication (16-128 chars, requires transit encryption)"
  type        = string
  sensitive   = true
}

# ============================================================================
# OPTIONAL VARIABLES
# ============================================================================

variable "port" {
  description = "Port on which Redis accepts connections"
  type        = number
  default     = 6379
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.r6g.large"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (nodes). 2+ enables Multi-AZ with automatic failover"
  type        = number
  default     = 2
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "parameters" {
  description = "List of Redis parameters to apply"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# ============================================================================
# MAINTENANCE AND BACKUP
# ============================================================================

variable "maintenance_window" {
  description = "Weekly time range for maintenance (UTC)"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "snapshot_window" {
  description = "Daily time range for snapshots (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots (0 disables backups)"
  type        = number
  default     = 7
}

# ============================================================================
# SECURITY
# ============================================================================

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access Redis"
  type        = list(string)
  default     = []
}

# ============================================================================
# NOTIFICATIONS
# ============================================================================

variable "notification_topic_arn" {
  description = "ARN of SNS topic for ElastiCache notifications"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
