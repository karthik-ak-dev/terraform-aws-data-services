# ============================================================================
# VARIABLES FOR VALKEY SERVERLESS MODULE
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
  description = "List of subnet IDs for the Valkey cluster"
  type        = list(string)
}

variable "auth_token" {
  description = "Auth token for Valkey authentication"
  type        = string
  sensitive   = true
}

# ============================================================================
# OPTIONAL VARIABLES
# ============================================================================

variable "admin_username" {
  description = "Username for the admin user"
  type        = string
  default     = "admin"
}

# ============================================================================
# SCALING LIMITS
# ============================================================================

variable "max_data_storage_gb" {
  description = "Maximum data storage in GB (1-5000)"
  type        = number
  default     = 10
}

variable "max_ecpu_per_second" {
  description = "Maximum ElastiCache Processing Units per second (1000-15000000)"
  type        = number
  default     = 5000
}

# ============================================================================
# BACKUP
# ============================================================================

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots (0-35)"
  type        = number
  default     = 7
}

variable "daily_snapshot_time" {
  description = "Time for daily snapshot in UTC (HH:MM)"
  type        = string
  default     = "03:00"
}

# ============================================================================
# SECURITY
# ============================================================================

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access Valkey"
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "KMS key ID for encryption at rest"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
