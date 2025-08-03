# EFS Storage Configuration for Persistent Data
# Provides secure, scalable file storage for containerized applications

# KMS Key for EFS encryption
resource "aws_kms_key" "efs" {
  count                   = var.enable_efs && var.create_efs_kms_key ? 1 : 0
  description             = "KMS key for EFS encryption"
  deletion_window_in_days = var.efs_kms_key_deletion_window
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EFS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "elasticfilesystem.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-efs-kms-key"
    Type = "kms-key"
  })
}

resource "aws_kms_alias" "efs" {
  count         = var.enable_efs && var.create_efs_kms_key ? 1 : 0
  name          = "alias/${local.name_prefix}-efs"
  target_key_id = aws_kms_key.efs[0].key_id
}

# EFS File System
resource "aws_efs_file_system" "main" {
  count = var.enable_efs ? 1 : 0

  creation_token   = "${local.name_prefix}-efs"
  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode

  # Provisioned throughput (only when throughput_mode is "provisioned")
  provisioned_throughput_in_mibps = var.efs_throughput_mode == "provisioned" ? var.efs_provisioned_throughput : null

  encrypted  = var.efs_encrypted
  kms_key_id = var.efs_encrypted ? (var.create_efs_kms_key ? aws_kms_key.efs[0].arn : var.efs_kms_key_id) : null

  # Lifecycle policies
  dynamic "lifecycle_policy" {
    for_each = var.efs_transition_to_ia != "" ? [1] : []
    content {
      transition_to_ia = var.efs_transition_to_ia
    }
  }

  dynamic "lifecycle_policy" {
    for_each = var.efs_transition_to_primary_storage_class != "" ? [1] : []
    content {
      transition_to_primary_storage_class = var.efs_transition_to_primary_storage_class
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-efs"
    Type = "efs-filesystem"
  })
}

# EFS Mount Targets
resource "aws_efs_mount_target" "main" {
  count           = var.enable_efs ? length(local.private_subnets) : 0
  file_system_id  = aws_efs_file_system.main[0].id
  subnet_id       = local.private_subnets[count.index]
  security_groups = [aws_security_group.efs[0].id]
}

# Security Group for EFS
resource "aws_security_group" "efs" {
  count       = var.enable_efs ? 1 : 0
  name        = "${local.name_prefix}-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = local.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-efs-sg"
    Type = "efs-security-group"
  })
}

# EFS Security Group Rules
resource "aws_vpc_security_group_ingress_rule" "efs_nfs" {
  count             = var.enable_efs && var.create_ecs_service ? 1 : 0
  security_group_id = aws_security_group.efs[0].id
  description       = "NFS from ECS tasks"

  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_tasks[0].id

  tags = {
    Name = "efs-nfs-ingress"
  }
}

resource "aws_vpc_security_group_egress_rule" "efs_all" {
  count             = var.enable_efs ? 1 : 0
  security_group_id = aws_security_group.efs[0].id
  description       = "All outbound traffic"

  from_port   = 0
  to_port     = 0
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "efs-all-egress"
  }
}

# EFS Access Points
resource "aws_efs_access_point" "main" {
  for_each       = var.enable_efs ? var.efs_access_points : {}
  file_system_id = aws_efs_file_system.main[0].id

  root_directory {
    path = each.value.root_directory_path
    creation_info {
      owner_gid   = each.value.owner_gid
      owner_uid   = each.value.owner_uid
      permissions = each.value.permissions
    }
  }

  posix_user {
    gid            = each.value.posix_gid
    uid            = each.value.posix_uid
    secondary_gids = each.value.secondary_gids
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-efs-ap-${each.key}"
    Type = "efs-access-point"
  })
}

# EFS Backup Policy
resource "aws_efs_backup_policy" "main" {
  count          = var.enable_efs && var.enable_efs_backup ? 1 : 0
  file_system_id = aws_efs_file_system.main[0].id

  backup_policy {
    status = "ENABLED"
  }
}

# S3 bucket for application logs and data (if needed)
resource "aws_s3_bucket" "app_data" {
  count         = var.create_s3_bucket ? 1 : 0
  bucket        = "${local.name_prefix}-app-data-${random_id.bucket_suffix[0].hex}"
  force_destroy = var.s3_force_destroy

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-data"
    Type = "s3-bucket"
  })
}

resource "random_id" "bucket_suffix" {
  count       = var.create_s3_bucket ? 1 : 0
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "app_data" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.app_data[0].id

  versioning_configuration {
    status = var.s3_versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.app_data[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.s3_kms_key_id
      sse_algorithm     = var.s3_kms_key_id != "" ? "aws:kms" : "AES256"
    }
    bucket_key_enabled = var.s3_kms_key_id != "" ? true : false
  }
}

resource "aws_s3_bucket_public_access_block" "app_data" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.app_data[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "app_data" {
  count  = var.create_s3_bucket && length(var.s3_lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.app_data[0].id

  dynamic "rule" {
    for_each = var.s3_lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [1] : []
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }
    }
  }
}