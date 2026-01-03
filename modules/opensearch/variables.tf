# ============================================================================
# VARIABLES FOR AMAZON OPENSEARCH MODULE
# ============================================================================

# ============================================================================
# REQUIRED VARIABLES
# ============================================================================

variable "name" {
  description = "Name of the OpenSearch domain (must be lowercase, 3-28 characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,27}$", var.name))
    error_message = "Domain name must be lowercase, start with a letter, and be 3-28 characters."
  }
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
  description = "List of subnet IDs for the OpenSearch domain"
  type        = list(string)
}

# ============================================================================
# ENGINE CONFIGURATION
# ============================================================================

variable "engine_version" {
  description = "OpenSearch engine version (e.g., OpenSearch_2.11)"
  type        = string
  default     = "OpenSearch_2.11"
}

# ============================================================================
# CLUSTER CONFIGURATION
# ============================================================================

variable "instance_type" {
  description = "Instance type for data nodes"
  type        = string
  default     = "r6g.large.search"
}

variable "instance_count" {
  description = "Number of data nodes"
  type        = number
  default     = 2
}

variable "dedicated_master_enabled" {
  description = "Enable dedicated master nodes"
  type        = bool
  default     = false
}

variable "dedicated_master_type" {
  description = "Instance type for dedicated master nodes"
  type        = string
  default     = "r6g.large.search"
}

variable "dedicated_master_count" {
  description = "Number of dedicated master nodes (must be 3 or 5)"
  type        = number
  default     = 3
}

variable "zone_awareness_enabled" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "availability_zone_count" {
  description = "Number of availability zones (2 or 3)"
  type        = number
  default     = 2
}

# ============================================================================
# WARM AND COLD STORAGE
# ============================================================================

variable "warm_enabled" {
  description = "Enable UltraWarm storage"
  type        = bool
  default     = false
}

variable "warm_type" {
  description = "Instance type for UltraWarm nodes"
  type        = string
  default     = "ultrawarm1.medium.search"
}

variable "warm_count" {
  description = "Number of UltraWarm nodes"
  type        = number
  default     = 2
}

variable "cold_storage_enabled" {
  description = "Enable cold storage"
  type        = bool
  default     = false
}

# ============================================================================
# EBS STORAGE
# ============================================================================

variable "ebs_volume_type" {
  description = "EBS volume type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "ebs_volume_size" {
  description = "EBS volume size in GB per data node"
  type        = number
  default     = 100
}

variable "ebs_iops" {
  description = "IOPS for gp3 volumes"
  type        = number
  default     = 3000
}

variable "ebs_throughput" {
  description = "Throughput in MB/s for gp3 volumes"
  type        = number
  default     = 125
}

# ============================================================================
# SECURITY
# ============================================================================

variable "kms_key_id" {
  description = "KMS key ID for encryption at rest"
  type        = string
  default     = null
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access OpenSearch"
  type        = list(string)
  default     = []
}

variable "access_policies_principals" {
  description = "List of IAM principals for access policies"
  type        = list(string)
  default     = ["*"]
}

variable "custom_access_policy" {
  description = "Custom access policy JSON (overrides default)"
  type        = string
  default     = null
}

variable "tls_security_policy" {
  description = "TLS security policy"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

# ============================================================================
# FINE-GRAINED ACCESS CONTROL
# ============================================================================

variable "fine_grained_access_enabled" {
  description = "Enable fine-grained access control"
  type        = bool
  default     = true
}

variable "internal_user_database_enabled" {
  description = "Enable internal user database"
  type        = bool
  default     = true
}

variable "master_user_name" {
  description = "Master user name for fine-grained access control"
  type        = string
  default     = "admin"
}

variable "master_user_password" {
  description = "Master user password for fine-grained access control"
  type        = string
  sensitive   = true
  default     = null
}

# ============================================================================
# AUTO-TUNE
# ============================================================================

variable "auto_tune_enabled" {
  description = "Enable Auto-Tune"
  type        = bool
  default     = true
}

# ============================================================================
# LOGGING
# ============================================================================

variable "log_publishing_options" {
  description = "List of log publishing options"
  type = list(object({
    cloudwatch_log_group_arn = string
    log_type                 = string # INDEX_SLOW_LOGS, SEARCH_SLOW_LOGS, ES_APPLICATION_LOGS, AUDIT_LOGS
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
