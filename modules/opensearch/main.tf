# ============================================================================
# AMAZON OPENSEARCH MODULE
# ============================================================================
#
# This module creates a production-ready Amazon OpenSearch Service domain with:
# - Multi-AZ deployment for high availability
# - Encryption at rest and in transit
# - Fine-grained access control
# - VPC deployment for network isolation
# - Auto-tune for performance optimization
# - UltraWarm and Cold storage tiers (optional)
#
# Amazon OpenSearch Service is a managed service for interactive log analytics,
# real-time application monitoring, website search, and more.

# ============================================================================
# SECURITY GROUP
# ============================================================================

resource "aws_security_group" "opensearch" {
  name        = "${var.name}-opensearch-sg"
  description = "Security group for OpenSearch domain"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS access from VPC"
    cidr_blocks = [var.vpc_cidr]
  }

  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      description     = "HTTPS access from security group"
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
    Name = "${var.name}-opensearch-sg"
  })
}

# ============================================================================
# SERVICE-LINKED ROLE (if needed)
# ============================================================================

data "aws_iam_policy_document" "opensearch_access" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.access_policies_principals
    }
    actions   = ["es:*"]
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.name}/*"]
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ============================================================================
# OPENSEARCH DOMAIN
# ============================================================================

resource "aws_opensearch_domain" "main" {
  domain_name    = var.name
  engine_version = var.engine_version

  # Cluster configuration
  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type    = var.dedicated_master_enabled ? var.dedicated_master_type : null
    dedicated_master_count   = var.dedicated_master_enabled ? var.dedicated_master_count : null
    zone_awareness_enabled   = var.zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled ? [1] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }

    # Warm storage (UltraWarm)
    warm_enabled = var.warm_enabled
    warm_type    = var.warm_enabled ? var.warm_type : null
    warm_count   = var.warm_enabled ? var.warm_count : null

    # Cold storage
    cold_storage_options {
      enabled = var.cold_storage_enabled
    }
  }

  # VPC configuration
  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.opensearch.id]
  }

  # EBS storage
  ebs_options {
    ebs_enabled = true
    volume_type = var.ebs_volume_type
    volume_size = var.ebs_volume_size
    iops        = var.ebs_volume_type == "gp3" ? var.ebs_iops : null
    throughput  = var.ebs_volume_type == "gp3" ? var.ebs_throughput : null
  }

  # Encryption
  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_id
  }

  node_to_node_encryption {
    enabled = true
  }

  # Access policies
  access_policies = var.custom_access_policy != null ? var.custom_access_policy : data.aws_iam_policy_document.opensearch_access.json

  # Fine-grained access control
  advanced_security_options {
    enabled                        = var.fine_grained_access_enabled
    internal_user_database_enabled = var.internal_user_database_enabled

    dynamic "master_user_options" {
      for_each = var.fine_grained_access_enabled ? [1] : []
      content {
        master_user_name     = var.master_user_name
        master_user_password = var.master_user_password
      }
    }
  }

  # Domain endpoint options
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = var.tls_security_policy
  }

  # Auto-Tune
  auto_tune_options {
    desired_state       = var.auto_tune_enabled ? "ENABLED" : "DISABLED"
    rollback_on_disable = "NO_ROLLBACK"
  }

  # Logging
  dynamic "log_publishing_options" {
    for_each = var.log_publishing_options
    content {
      cloudwatch_log_group_arn = log_publishing_options.value.cloudwatch_log_group_arn
      log_type                 = log_publishing_options.value.log_type
      enabled                  = true
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
