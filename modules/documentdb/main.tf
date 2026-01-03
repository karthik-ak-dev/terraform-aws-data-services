# ============================================================================
# AMAZON DOCUMENTDB MODULE
# ============================================================================
#
# This module creates a production-ready Amazon DocumentDB cluster with:
# - MongoDB 5.0/6.0 compatibility
# - Multi-AZ deployment for high availability
# - Encryption at rest and in transit
# - Configurable instance count
# - Automated backups
#
# Amazon DocumentDB is a scalable, highly durable, and fully managed
# document database service that supports MongoDB workloads.

# ============================================================================
# NETWORKING
# ============================================================================

resource "aws_docdb_subnet_group" "main" {
  name       = "${var.name}-docdb-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-docdb-subnet-group"
  })
}

resource "aws_security_group" "docdb" {
  name        = "${var.name}-docdb-sg"
  description = "Security group for DocumentDB cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    description = "DocumentDB access from VPC"
    cidr_blocks = [var.vpc_cidr]
  }

  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      from_port       = var.port
      to_port         = var.port
      protocol        = "tcp"
      description     = "DocumentDB access from security group"
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
    Name = "${var.name}-docdb-sg"
  })
}

# ============================================================================
# PARAMETER GROUP
# ============================================================================

resource "aws_docdb_cluster_parameter_group" "main" {
  name   = "${var.name}-docdb-params"
  family = "docdb${var.engine_version}"

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "pending-reboot")
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-docdb-params"
  })
}

# ============================================================================
# DOCUMENTDB CLUSTER
# ============================================================================

resource "aws_docdb_cluster" "main" {
  cluster_identifier = "${var.name}-docdb-cluster"
  engine             = "docdb"
  engine_version     = var.engine_version

  master_username = var.master_username
  master_password = var.master_password
  port            = var.port

  db_subnet_group_name            = aws_docdb_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.docdb.id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  storage_encrypted = true
  kms_key_id        = var.kms_key_id

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-docdb-final-snapshot"

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = merge(var.tags, {
    Name = "${var.name}-docdb-cluster"
  })
}

# ============================================================================
# DOCUMENTDB INSTANCES
# ============================================================================

resource "aws_docdb_cluster_instance" "main" {
  count = var.instance_count

  identifier           = "${var.name}-docdb-instance-${count.index}"
  cluster_identifier   = aws_docdb_cluster.main.id
  instance_class       = var.instance_class
  engine               = "docdb"
  promotion_tier       = count.index

  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  tags = merge(var.tags, {
    Name = "${var.name}-docdb-instance-${count.index}"
  })
}
