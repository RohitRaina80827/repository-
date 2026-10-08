
# ============================================================
# Provisioning Role
# ============================================================

resource "aws_iam_role" "provisioning" {
  name = "${local.security_name}-provisioning"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::980819806665:root"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.network_tags
}


# ============================================================
# Provisioning Role - Pass ONLY the Runtime Role to EC2
# ============================================================

resource "aws_iam_role_policy" "provisioning_pass_runtime" {
  name = "${local.security_name}-pass-runtime"

  role = aws_iam_role.provisioning.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "PassApprovedRuntimeRoleToEC2"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.runtime.arn

        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ec2.amazonaws.com"
          }
        }
      }
    ]
  })
}


# ============================================================
# Runtime Instance Profile
# ============================================================

resource "aws_iam_instance_profile" "runtime" {
  name = "${local.security_name}-runtime-profile"

  role = aws_iam_role.runtime.name

  tags = local.network_tags
}


# ============================================================
# Runtime Role - AWS Systems Manager
# ============================================================

resource "aws_iam_role_policy_attachment" "runtime_ssm" {
  role = aws_iam_role.runtime.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# ============================================================
# Runtime Role - Artifact Read Access
# ============================================================

resource "aws_iam_role_policy" "runtime_artifact_read" {
  name = "${local.security_name}-artifact-read"

  role = aws_iam_role.runtime.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # --------------------------------------------------------
      # Allow listing only the configured artifact prefix
      # --------------------------------------------------------
      {
        Sid      = "ListArtifactPrefix"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = module.storage.bucket_arn

        Condition = {
          StringLike = {
            "s3:prefix" = "${var.artifact_prefix}*"
          }
        }
      },

      # --------------------------------------------------------
      # Allow reading objects only under the artifact prefix
      # --------------------------------------------------------
      {
        Sid      = "ReadArtifactObjects"
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${module.storage.bucket_arn}/${var.artifact_prefix}*"
      }
    ]
  })
}
