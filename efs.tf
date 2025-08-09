# EFS File System
resource "aws_efs_file_system" "main" {
  count            = var.create_efs ? 1 : 0
  creation_token   = "${var.name}-efs"
  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode
  encrypted        = var.efs_encrypted
  kms_key_id       = var.efs_kms_key_id != "" ? var.efs_kms_key_id : null

  provisioned_throughput_in_mibps = var.efs_throughput_mode == "provisioned" ? var.efs_provisioned_throughput : null

  dynamic "lifecycle_policy" {
    for_each = var.efs_lifecycle_policy != "" ? [1] : []
    content {
      transition_to_ia = var.efs_lifecycle_policy
    }
  }

  tags = merge(local.common_tags, {
    name = var.efs_name != "" ? var.efs_name : "${var.name}-efs"
  })
}

# EFS Backup Policy
resource "aws_efs_backup_policy" "main" {
  count          = var.create_efs ? 1 : 0
  file_system_id = aws_efs_file_system.main[0].id

  backup_policy {
    status = var.efs_backup_policy
  }
}

# Security Group for EFS
resource "aws_security_group" "efs" {
  count       = var.create_efs ? 1 : 0
  name        = "${var.name}-efs"
  description = "Security group for EFS filesystem"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { name = "${var.name}-efs" })

  # Ingress rules moved to separate resources to avoid circular dependency

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EFS Mount Targets
resource "aws_efs_mount_target" "main" {
  count           = var.create_efs ? length(local.efs_subnets) : 0
  file_system_id  = aws_efs_file_system.main[0].id
  subnet_id       = local.efs_subnets[count.index]
  security_groups = [aws_security_group.efs[0].id]
}

# EFS Access Points
resource "aws_efs_access_point" "main" {
  count          = var.create_efs ? length(var.efs_access_points) : 0
  file_system_id = aws_efs_file_system.main[0].id
  tags = merge(local.common_tags, {
    name = "${var.name}-${var.efs_access_points[count.index].name}"
  })

  root_directory {
    path = var.efs_access_points[count.index].path

    dynamic "creation_info" {
      for_each = var.efs_access_points[count.index].creation_info != null ? [var.efs_access_points[count.index].creation_info] : []
      content {
        owner_gid   = creation_info.value.owner_gid
        owner_uid   = creation_info.value.owner_uid
        permissions = creation_info.value.permissions
      }
    }
  }

  dynamic "posix_user" {
    for_each = var.efs_access_points[count.index].posix_user != null ? [var.efs_access_points[count.index].posix_user] : []
    content {
      gid            = posix_user.value.gid
      uid            = posix_user.value.uid
      secondary_gids = posix_user.value.secondary_gids
    }
  }
}

# Local values for EFS
locals {
  efs_subnets = var.create_efs ? (
    length(var.efs_mount_targets_subnets) > 0 ? var.efs_mount_targets_subnets : var.private_subnets
  ) : []

  # Create EFS volume configurations for task definition
  efs_volumes = var.create_efs ? [
    for mount_point in var.efs_mount_points : {
      name = mount_point.source_volume
      efs_volume_configuration = {
        file_system_id          = aws_efs_file_system.main[0].id
        root_directory          = "/"
        transit_encryption      = "ENABLED"
        transit_encryption_port = 2049
        authorization_config = mount_point.access_point_id != "" ? {
          access_point_id = mount_point.access_point_id
          iam             = "DISABLED"
        } : null
      }
    }
  ] : []

  # Create mount points for container definition
  efs_mount_points = var.create_efs ? [
    for mount_point in var.efs_mount_points : {
      sourceVolume  = mount_point.source_volume
      containerPath = mount_point.container_path
      readOnly      = mount_point.read_only
    }
  ] : []
}

# Separate security group rules for EFS to avoid circular dependencies

# EFS from ECS Tasks ingress rule
resource "aws_security_group_rule" "efs_from_ecs_tasks" {
  count                    = var.create_efs ? 1 : 0
  type                     = "ingress"
  description              = "NFS from ECS tasks"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks.id
  security_group_id        = aws_security_group.efs[0].id
}

# EFS from EC2 instances ingress rule (when using EC2 launch type)
resource "aws_security_group_rule" "efs_from_ec2_instances" {
  count                    = var.launch_type == "EC2" && var.create_efs ? 1 : 0
  type                     = "ingress"
  description              = "NFS from EC2 instances"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_instances[0].id
  security_group_id        = aws_security_group.efs[0].id
}