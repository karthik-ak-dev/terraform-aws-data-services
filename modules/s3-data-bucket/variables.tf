# ============================================================================
# VARIABLES FOR S3 DATA BUCKET MODULE
# ============================================================================

# ============================================================================
# REQUIRED VARIABLES
# ============================================================================

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

# ============================================================================
# OPTIONAL VARIABLES
# ============================================================================

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

# ============================================================================
# VERSIONING
# ============================================================================

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

# ============================================================================
# ENCRYPTION
# ============================================================================

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS encryption (null for SSE-S3)"
  type        = string
  default     = null
}

# ============================================================================
# ACCESS CONTROL
# ============================================================================

variable "block_public_access" {
  description = "Block all public access to the bucket"
  type        = bool
  default     = true
}

variable "bucket_policy" {
  description = "Bucket policy JSON document"
  type        = string
  default     = null
}

# ============================================================================
# LIFECYCLE RULES
# ============================================================================

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    id      = string
    enabled = bool
    prefix  = optional(string)
    transitions = optional(list(object({
      days          = number
      storage_class = string # STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, GLACIER_IR, DEEP_ARCHIVE
    })))
    expiration_days                        = optional(number)
    noncurrent_version_expiration_days     = optional(number)
    abort_incomplete_multipart_upload_days = optional(number)
    noncurrent_version_transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = [
    {
      id      = "transition-to-ia"
      enabled = true
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration_days     = 90
      abort_incomplete_multipart_upload_days = 7
    }
  ]
}

# ============================================================================
# LOGGING
# ============================================================================

variable "logging_bucket" {
  description = "Target bucket for access logs"
  type        = string
  default     = null
}

variable "logging_prefix" {
  description = "Prefix for access log objects"
  type        = string
  default     = null
}

# ============================================================================
# CORS
# ============================================================================

variable "cors_rules" {
  description = "List of CORS rules"
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

# ============================================================================
# INTELLIGENT TIERING
# ============================================================================

variable "intelligent_tiering_enabled" {
  description = "Enable Intelligent-Tiering configuration"
  type        = bool
  default     = false
}

variable "intelligent_tiering_archive_days" {
  description = "Days before transitioning to Archive Access tier"
  type        = number
  default     = 90
}

variable "intelligent_tiering_deep_archive_days" {
  description = "Days before transitioning to Deep Archive Access tier"
  type        = number
  default     = 180
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
