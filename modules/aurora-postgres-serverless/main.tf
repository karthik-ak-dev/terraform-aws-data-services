# ============================================================================
# AURORA POSTGRESQL SERVERLESS V2 MODULE
# ============================================================================
#
# This module creates an Amazon Aurora PostgreSQL Serverless v2 cluster with:
# - Auto-scaling capacity based on workload (ACUs)
# - Pay-per-use pricing model
# - Encryption at rest and in transit
# - Security group with VPC-scoped access
#
# Aurora Serverless v2 automatically scales capacity in fine-grained increments
# to match your application's needs, scaling to hundreds of thousands of
# transactions per second in a fraction of a second.

# ============================================================================
# NETWORKING
# ============================================================================

resource "aws_db_subnet_group" "aurora_serverless" {
  name       = "${var.name}-aurora-serverless-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-serverless-subnet-group"
  })
}

resource "aws_security_group" "aurora_serverless" {
  name        = "${var.name}-aurora-serverless-sg"
  description = "Security group for Aurora PostgreSQL Serverless cluster"
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
    Name = "${var.name}-aurora-serverless-sg"
  })
}

# ============================================================================
# PARAMETER GROUP
# ============================================================================

locals {
  major_version = length(regexall("\\.", var.engine_version)) > 0 ? split(".", var.engine_version)[0] : var.engine_version
}

resource "aws_rds_cluster_parameter_group" "aurora_serverless" {
  name   = "${var.name}-aurora-serverless-params"
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
    Name = "${var.name}-aurora-serverless-params"
  })
}

# ============================================================================
# AURORA SERVERLESS CLUSTER
# ============================================================================

resource "aws_rds_cluster" "aurora_serverless" {
  cluster_identifier = "${var.name}-aurora-serverless-cluster"
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version
  engine_mode        = "provisioned" # Serverless v2 uses provisioned mode

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password
  port            = var.port

  db_subnet_group_name            = aws_db_subnet_group.aurora_serverless.name
  vpc_security_group_ids          = [aws_security_group.aurora_serverless.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_serverless.name

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  storage_encrypted   = true
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-aurora-serverless-final-snapshot"

  # Serverless v2 scaling configuration
  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-serverless-cluster"
  })

  lifecycle {
    ignore_changes = [availability_zones]
  }
}

# ============================================================================
# AURORA SERVERLESS INSTANCE
# ============================================================================

resource "aws_rds_cluster_instance" "aurora_serverless" {
  count = var.instance_count

  identifier           = "${var.name}-aurora-serverless-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.aurora_serverless.id
  instance_class       = "db.serverless"
  engine               = aws_rds_cluster.aurora_serverless.engine
  engine_version       = aws_rds_cluster.aurora_serverless.engine_version
  db_subnet_group_name = aws_db_subnet_group.aurora_serverless.name
  publicly_accessible  = var.publicly_accessible

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-serverless-instance-${count.index}"
  })
}
