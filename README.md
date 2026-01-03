# Terraform AWS Data Services

Production-ready Terraform modules for AWS data services including databases, caching, search, and storage.

## Overview

This repository provides a comprehensive collection of modules for building a complete data layer on AWS:

- **Relational Databases**: Aurora PostgreSQL (provisioned and serverless)
- **NoSQL Databases**: DynamoDB, DocumentDB (MongoDB-compatible)
- **Caching**: ElastiCache Redis, Valkey Serverless
- **Search & Analytics**: OpenSearch
- **Object Storage**: S3 with lifecycle policies

All modules are designed with production best practices: encryption at rest/transit, high availability, backup/recovery, and security group isolation.

## Architecture

```
┌────────────────────────────────────────────────────────────────────────────┐
│                           AWS Data Services                                │
│                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    RELATIONAL DATABASES                             │   │
│  │  ┌─────────────────────┐    ┌─────────────────────┐                 │   │
│  │  │  Aurora PostgreSQL  │    │  Aurora Serverless  │                 │   │
│  │  │  (Provisioned)      │    │  (Auto-scaling)     │                 │   │
│  │  │  • Multi-AZ         │    │  • 0.5-128 ACUs     │                 │   │
│  │  │  • Read replicas    │    │  • Pay-per-use      │                 │   │
│  │  └─────────────────────┘    └─────────────────────┘                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      NOSQL DATABASES                                │   │
│  │  ┌─────────────────────┐    ┌─────────────────────┐                 │   │
│  │  │     DynamoDB        │    │     DocumentDB      │                 │   │
│  │  │  • On-demand/Prov   │    │  • MongoDB compat   │                 │   │
│  │  │  • Auto-scaling     │    │  • Multi-AZ         │                 │   │
│  │  │  • GSI/LSI support  │    │  • TLS encryption   │                 │   │
│  │  └─────────────────────┘    └─────────────────────┘                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         CACHING                                     │   │
│  │  ┌─────────────────────┐    ┌─────────────────────┐                 │   │
│  │  │   ElastiCache Redis │    │  Valkey Serverless  │                 │   │
│  │  │  • Multi-AZ         │    │  • Auto-scaling     │                 │   │
│  │  │  • Auth token       │    │  • Pay-per-use      │                 │   │
│  │  │  • Encryption       │    │  • Redis compatible │                 │   │
│  │  └─────────────────────┘    └─────────────────────┘                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │              SEARCH & ANALYTICS          OBJECT STORAGE             │   │
│  │  ┌─────────────────────┐    ┌─────────────────────┐                 │   │
│  │  │     OpenSearch      │    │    S3 Data Bucket   │                 │   │
│  │  │  • Multi-AZ         │    │  • Versioning       │                 │   │
│  │  │  • Fine-grained ACL │    │  • Lifecycle rules  │                 │   │
│  │  │  • UltraWarm/Cold   │    │  • Encryption       │                 │   │
│  │  └─────────────────────┘    └─────────────────────┘                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────────┘
```

## Modules

| Module | Description | Key Features |
|--------|-------------|--------------|
| [aurora-postgres](./modules/aurora-postgres) | Aurora PostgreSQL provisioned | Multi-AZ, read replicas, encryption |
| [aurora-postgres-serverless](./modules/aurora-postgres-serverless) | Aurora PostgreSQL Serverless v2 | Auto-scaling ACUs, pay-per-use |
| [dynamodb](./modules/dynamodb) | DynamoDB table | On-demand/provisioned, GSI/LSI, streams |
| [documentdb](./modules/documentdb) | DocumentDB cluster | MongoDB 5.0/6.0 compatible, Multi-AZ |
| [redis](./modules/redis) | ElastiCache Redis | Multi-AZ, auth token, encryption |
| [valkey-serverless](./modules/valkey-serverless) | Valkey Serverless | Auto-scaling, Redis OSS compatible |
| [opensearch](./modules/opensearch) | OpenSearch domain | Fine-grained access, UltraWarm, VPC |
| [s3-data-bucket](./modules/s3-data-bucket) | S3 bucket | Versioning, lifecycle, encryption |

## Quick Start

### Aurora PostgreSQL

```hcl
module "aurora" {
  source = "github.com/YOUR_USERNAME/terraform-aws-data-services//modules/aurora-postgres"

  name       = "myapp"
  vpc_id     = "vpc-xxx"
  vpc_cidr   = "10.0.0.0/16"
  subnet_ids = ["subnet-xxx", "subnet-yyy"]

  master_password = var.db_password
  instance_class  = "db.r6g.large"
  instance_count  = 2
}
```

### DynamoDB

```hcl
module "dynamodb" {
  source = "github.com/YOUR_USERNAME/terraform-aws-data-services//modules/dynamodb"

  table_name = "orders"
  hash_key   = "pk"
  range_key  = "sk"

  attributes = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" }
  ]

  billing_mode                   = "PAY_PER_REQUEST"
  point_in_time_recovery_enabled = true
}
```

### Redis

```hcl
module "redis" {
  source = "github.com/YOUR_USERNAME/terraform-aws-data-services//modules/redis"

  name       = "myapp"
  vpc_id     = "vpc-xxx"
  vpc_cidr   = "10.0.0.0/16"
  subnet_ids = ["subnet-xxx", "subnet-yyy"]

  node_type          = "cache.r6g.large"
  num_cache_clusters = 2
  auth_token         = var.redis_auth_token
}
```

### S3 Data Bucket

```hcl
module "data_bucket" {
  source = "github.com/YOUR_USERNAME/terraform-aws-data-services//modules/s3-data-bucket"

  bucket_name        = "myapp-data-us-east-1"
  versioning_enabled = true

  lifecycle_rules = [
    {
      id      = "archive"
      enabled = true
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 90, storage_class = "GLACIER" }
      ]
    }
  ]
}
```

## Security Features

All modules implement AWS security best practices:

| Feature | Description |
|---------|-------------|
| **Encryption at Rest** | SSE-S3, SSE-KMS, or service-native encryption |
| **Encryption in Transit** | TLS/SSL for all connections |
| **Network Isolation** | VPC deployment with security groups |
| **Authentication** | IAM, auth tokens, master passwords |
| **Access Control** | Fine-grained permissions, bucket policies |
| **Backup & Recovery** | Automated backups, point-in-time recovery |

## Module Comparison

### When to Use What?

| Use Case | Recommended Module |
|----------|-------------------|
| OLTP workloads, complex queries | Aurora PostgreSQL |
| Variable/unpredictable workloads | Aurora Serverless |
| High-throughput key-value | DynamoDB |
| MongoDB migration | DocumentDB |
| Session cache, real-time | Redis |
| Serverless caching | Valkey Serverless |
| Log analytics, full-text search | OpenSearch |
| Data lake, backups, static assets | S3 |

### Cost Optimization Tips

| Module | Cost Tip |
|--------|----------|
| Aurora | Use Serverless for dev/test, provisioned for production |
| DynamoDB | Use on-demand for variable traffic, provisioned with auto-scaling for predictable |
| Redis | Right-size node types, use Valkey Serverless for variable workloads |
| OpenSearch | Enable UltraWarm for older data, use gp3 EBS |
| S3 | Implement lifecycle rules, use Intelligent-Tiering |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Complete Example

See [examples/complete](./examples/complete) for a full example deploying all data services.

```bash
cd examples/complete
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Karthik**

*AWS Platform Engineer specializing in data infrastructure, database architecture, and cloud-native solutions.*
