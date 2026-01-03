# ============================================================================
# COMPLETE DATA SERVICES EXAMPLE
# ============================================================================
#
# This example demonstrates how to use the terraform-aws-data-services modules
# to create a complete data layer including:
# - Aurora PostgreSQL (provisioned and serverless)
# - ElastiCache Redis
# - Valkey Serverless
# - DynamoDB
# - DocumentDB
# - OpenSearch
# - S3 Data Bucket

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ============================================================================
# DATA SOURCES
# ============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================================
# AURORA POSTGRESQL (PROVISIONED)
# ============================================================================

module "aurora_postgres" {
  source = "../../modules/aurora-postgres"

  name       = "${var.project_name}-aurora"
  vpc_id     = var.vpc_id
  vpc_cidr   = var.vpc_cidr
  subnet_ids = var.private_subnet_ids

  database_name   = "appdb"
  master_username = "postgres"
  master_password = var.aurora_master_password

  instance_class = "db.r6g.large"
  instance_count = 2

  backup_retention_period = 7
  deletion_protection     = var.deletion_protection

  tags = var.tags
}

# ============================================================================
# AURORA POSTGRESQL SERVERLESS
# ============================================================================

module "aurora_serverless" {
  source = "../../modules/aurora-postgres-serverless"

  name       = "${var.project_name}-aurora-serverless"
  vpc_id     = var.vpc_id
  vpc_cidr   = var.vpc_cidr
  subnet_ids = var.private_subnet_ids

  database_name   = "appdb"
  master_username = "postgres"
  master_password = var.aurora_master_password

  min_capacity = 0.5
  max_capacity = 4

  deletion_protection = var.deletion_protection

  tags = var.tags
}

# ============================================================================
# ELASTICACHE REDIS
# ============================================================================

module "redis" {
  source = "../../modules/redis"

  name       = var.project_name
  vpc_id     = var.vpc_id
  vpc_cidr   = var.vpc_cidr
  subnet_ids = var.private_subnet_ids

  node_type          = "cache.r6g.large"
  num_cache_clusters = 2
  auth_token         = var.redis_auth_token

  tags = var.tags
}

# ============================================================================
# VALKEY SERVERLESS
# ============================================================================

module "valkey" {
  source = "../../modules/valkey-serverless"

  name       = var.project_name
  vpc_id     = var.vpc_id
  vpc_cidr   = var.vpc_cidr
  subnet_ids = var.private_subnet_ids

  max_data_storage_gb = 10
  max_ecpu_per_second = 5000
  auth_token          = var.valkey_auth_token

  tags = var.tags
}

# ============================================================================
# DYNAMODB
# ============================================================================

module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name = "${var.project_name}-items"
  hash_key   = "pk"
  range_key  = "sk"

  attributes = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" },
    { name = "gsi1pk", type = "S" },
    { name = "gsi1sk", type = "S" }
  ]

  billing_mode = "PAY_PER_REQUEST"

  global_secondary_indexes = [
    {
      name            = "gsi1"
      hash_key        = "gsi1pk"
      range_key       = "gsi1sk"
      projection_type = "ALL"
    }
  ]

  point_in_time_recovery_enabled = true
  stream_enabled                 = true

  tags = var.tags
}

# ============================================================================
# DOCUMENTDB
# ============================================================================

module "documentdb" {
  source = "../../modules/documentdb"

  name       = var.project_name
  vpc_id     = var.vpc_id
  vpc_cidr   = var.vpc_cidr
  subnet_ids = var.private_subnet_ids

  master_username = "docdbadmin"
  master_password = var.documentdb_master_password

  instance_class = "db.r6g.large"
  instance_count = 2

  deletion_protection = var.deletion_protection

  tags = var.tags
}

# ============================================================================
# OPENSEARCH
# ============================================================================

module "opensearch" {
  source = "../../modules/opensearch"

  name       = replace(var.project_name, "_", "-")
  vpc_id     = var.vpc_id
  vpc_cidr   = var.vpc_cidr
  subnet_ids = var.private_subnet_ids

  instance_type  = "r6g.large.search"
  instance_count = 2

  ebs_volume_size = 100
  ebs_volume_type = "gp3"

  fine_grained_access_enabled = true
  master_user_name            = "admin"
  master_user_password        = var.opensearch_master_password

  tags = var.tags
}

# ============================================================================
# S3 DATA BUCKET
# ============================================================================

module "data_bucket" {
  source = "../../modules/s3-data-bucket"

  bucket_name = "${var.project_name}-data-${var.region}"

  versioning_enabled  = true
  block_public_access = true

  lifecycle_rules = [
    {
      id      = "archive-old-data"
      enabled = true
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 90, storage_class = "GLACIER" }
      ]
      noncurrent_version_expiration_days     = 90
      abort_incomplete_multipart_upload_days = 7
    }
  ]

  tags = var.tags
}
