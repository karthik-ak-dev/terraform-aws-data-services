# ============================================================================
# VARIABLES FOR DYNAMODB MODULE
# ============================================================================

# ============================================================================
# REQUIRED VARIABLES
# ============================================================================

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "hash_key" {
  description = "Attribute to use as the hash (partition) key"
  type        = string
}

variable "attributes" {
  description = "List of attribute definitions"
  type = list(object({
    name = string
    type = string # S (String), N (Number), B (Binary)
  }))
}

# ============================================================================
# OPTIONAL VARIABLES
# ============================================================================

variable "range_key" {
  description = "Attribute to use as the range (sort) key"
  type        = string
  default     = null
}

variable "billing_mode" {
  description = "Billing mode: PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "table_class" {
  description = "Table class: STANDARD or STANDARD_INFREQUENT_ACCESS"
  type        = string
  default     = "STANDARD"
}

# ============================================================================
# PROVISIONED CAPACITY
# ============================================================================

variable "read_capacity" {
  description = "Read capacity units (for PROVISIONED billing mode)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (for PROVISIONED billing mode)"
  type        = number
  default     = 5
}

# ============================================================================
# INDEXES
# ============================================================================

variable "global_secondary_indexes" {
  description = "List of Global Secondary Indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string # ALL, KEYS_ONLY, INCLUDE
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "List of Local Secondary Indexes"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string # ALL, KEYS_ONLY, INCLUDE
    non_key_attributes = optional(list(string))
  }))
  default = []
}

# ============================================================================
# TTL
# ============================================================================

variable "ttl_attribute" {
  description = "Attribute name for TTL (null to disable)"
  type        = string
  default     = null
}

# ============================================================================
# BACKUP AND RECOVERY
# ============================================================================

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

# ============================================================================
# ENCRYPTION
# ============================================================================

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (null for AWS-managed key)"
  type        = string
  default     = null
}

# ============================================================================
# STREAMS
# ============================================================================

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

# ============================================================================
# AUTO SCALING
# ============================================================================

variable "enable_autoscaling" {
  description = "Enable auto-scaling (only for PROVISIONED billing mode)"
  type        = bool
  default     = false
}

variable "autoscaling_read_max_capacity" {
  description = "Maximum read capacity for auto-scaling"
  type        = number
  default     = 100
}

variable "autoscaling_write_max_capacity" {
  description = "Maximum write capacity for auto-scaling"
  type        = number
  default     = 100
}

variable "autoscaling_target_value" {
  description = "Target utilization percentage for auto-scaling"
  type        = number
  default     = 70
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown in seconds before scaling in"
  type        = number
  default     = 60
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown in seconds before scaling out"
  type        = number
  default     = 60
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
