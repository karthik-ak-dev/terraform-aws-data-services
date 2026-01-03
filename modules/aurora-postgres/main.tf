# ============================================================================
# AURORA POSTGRESQL MODULE
# ============================================================================
#
# This module creates a production-ready Amazon Aurora PostgreSQL cluster with:
# - Multi-AZ deployment for high availability
# - Encryption at rest and in transit
# - Configurable instance count for read replicas
# - Security group with VPC-scoped access
# - Parameter group for performance tuning
#
# Aurora PostgreSQL provides up to 5x the throughput of standard PostgreSQL
# with built-in high availability and automatic failover.

# ============================================================================
# NETWORKING
# ============================================================================

resource "aws_db_subnet_group" "aurora" {
  name       = "${var.name}-aurora-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-subnet-group"
  })
}

resource "aws_security_group" "aurora" {
  name        = "${var.name}-aurora-sg"
  description = "Security group for Aurora PostgreSQL cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    description = "PostgreSQL access from VPC"
    cidr_blocks = [var.vpc_cidr]
  }

  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      from_port       = var.port
      to_port         = var.port
      protocol        = "tcp"
      description     = "PostgreSQL access from security group"
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
    Name = "${var.name}-aurora-sg"
  })
}

# ============================================================================
# PARAMETER GROUP
# ============================================================================

locals {
  major_version = length(regexall("\\.", var.engine_version)) > 0 ? split(".", var.engine_version)[0] : var.engine_version
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  name   = "${var.name}-aurora-params"
  family = "aurora-postgresql${local.major_version}"

  parameter {
    name  = "log_statement"
    value = var.log_statement
  }

  parameter {
    name  = "log_min_duration_statement"
    value = var.log_min_duration_statement
  }

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-params"
  })
}

# ============================================================================
# AURORA CLUSTER
# ============================================================================

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${var.name}-aurora-cluster"
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version
  engine_mode        = "provisioned"

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password
  port            = var.port

  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  vpc_security_group_ids          = [aws_security_group.aurora.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  storage_encrypted   = true
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-aurora-final-snapshot"

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-cluster"
  })

  lifecycle {
    ignore_changes = [availability_zones]
  }
}

# ============================================================================
# AURORA INSTANCES
# ============================================================================

resource "aws_rds_cluster_instance" "aurora" {
  count = var.instance_count

  identifier           = "${var.name}-aurora-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.aurora.id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.aurora.engine
  engine_version       = aws_rds_cluster.aurora.engine_version
  db_subnet_group_name = aws_db_subnet_group.aurora.name
  publicly_accessible  = var.publicly_accessible

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-instance-${count.index}"
  })
}
