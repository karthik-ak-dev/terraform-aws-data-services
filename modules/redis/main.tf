# ============================================================================
# ELASTICACHE REDIS MODULE
# ============================================================================
#
# This module creates a production-ready Amazon ElastiCache Redis cluster with:
# - Multi-AZ deployment with automatic failover
# - Encryption at rest and in transit
# - Auth token authentication
# - Configurable node count for read replicas
#
# ElastiCache Redis provides sub-millisecond latency for caching, session
# management, real-time analytics, and message queuing.

# ============================================================================
# NETWORKING
# ============================================================================

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.name}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-redis-subnet-group"
  })
}

resource "aws_security_group" "redis" {
  name        = "${var.name}-redis-sg"
  description = "Security group for ElastiCache Redis cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    description = "Redis access from VPC"
    cidr_blocks = [var.vpc_cidr]
  }

  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      from_port       = var.port
      to_port         = var.port
      protocol        = "tcp"
      description     = "Redis access from security group"
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
    Name = "${var.name}-redis-sg"
  })
}

# ============================================================================
# PARAMETER GROUP
# ============================================================================

locals {
  redis_major_version = split(".", var.engine_version)[0]
}

resource "aws_elasticache_parameter_group" "redis" {
  name   = "${var.name}-redis-params"
  family = "redis${local.redis_major_version}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-redis-params"
  })
}

# ============================================================================
# REDIS REPLICATION GROUP
# ============================================================================

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.name}-redis"
  description          = "Redis cluster for ${var.name}"

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  parameter_group_name = aws_elasticache_parameter_group.redis.name
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  # High availability settings
  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.num_cache_clusters > 1
  multi_az_enabled           = var.num_cache_clusters > 1

  # Security settings
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.auth_token

  # Maintenance settings
  maintenance_window       = var.maintenance_window
  snapshot_window          = var.snapshot_window
  snapshot_retention_limit = var.snapshot_retention_limit

  # Notifications
  notification_topic_arn = var.notification_topic_arn

  tags = merge(var.tags, {
    Name = "${var.name}-redis"
  })

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }
}
