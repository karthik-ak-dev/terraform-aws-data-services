# ============================================================================
# VALKEY SERVERLESS MODULE
# ============================================================================
#
# This module creates an Amazon ElastiCache Valkey Serverless cluster with:
# - Auto-scaling capacity based on workload
# - Pay-per-use pricing model
# - User-based authentication
# - Encryption at rest and in transit
#
# Valkey is an open-source, Redis OSS-compatible in-memory data store that
# provides sub-millisecond response times. Serverless automatically scales
# to handle your workload without capacity planning.

# ============================================================================
# NETWORKING
# ============================================================================

resource "aws_security_group" "valkey" {
  name        = "${var.name}-valkey-serverless-sg"
  description = "Security group for Valkey Serverless cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    description = "Valkey access from VPC"
    cidr_blocks = [var.vpc_cidr]
  }

  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      from_port       = 6379
      to_port         = 6379
      protocol        = "tcp"
      description     = "Valkey access from security group"
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-valkey-serverless-sg"
  })
}

# ============================================================================
# VALKEY USER AND USER GROUP
# ============================================================================

resource "aws_elasticache_user" "admin" {
  user_id       = "${var.name}-valkey-admin"
  user_name     = var.admin_username
  access_string = "on ~* +@all"
  engine        = "valkey"

  authentication_mode {
    type      = "password"
    passwords = [var.auth_token]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-valkey-admin"
  })
}

resource "aws_elasticache_user_group" "valkey" {
  user_group_id = "${var.name}-valkey-users"
  engine        = "valkey"
  user_ids      = [aws_elasticache_user.admin.user_id]

  tags = merge(var.tags, {
    Name = "${var.name}-valkey-users"
  })
}

# ============================================================================
# VALKEY SERVERLESS CACHE
# ============================================================================

resource "aws_elasticache_serverless_cache" "valkey" {
  engine      = "valkey"
  name        = "${var.name}-valkey-serverless"
  description = "Valkey Serverless cluster for ${var.name}"

  # Scaling limits
  cache_usage_limits {
    data_storage {
      maximum = var.max_data_storage_gb
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = var.max_ecpu_per_second
    }
  }

  # Networking
  security_group_ids = [aws_security_group.valkey.id]
  subnet_ids         = var.subnet_ids

  # Authentication
  user_group_id = aws_elasticache_user_group.valkey.user_group_id

  # Backup
  snapshot_retention_limit = var.snapshot_retention_limit
  daily_snapshot_time      = var.daily_snapshot_time

  # KMS encryption (optional)
  kms_key_id = var.kms_key_id

  tags = merge(var.tags, {
    Name = "${var.name}-valkey-serverless"
  })
}
