locals {
  bucket_arn = aws_s3_bucket.state.arn
}

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          local.bucket_arn,
          "${local.bucket_arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "DenyOtherObjectPrincipals"
        Effect    = "Deny"
        Principal = "*"

        Action = [
          "s3:GetObject*",
          "s3:PutObject*",
          "s3:DeleteObject*"
        ]

        Resource = "${local.bucket_arn}/*"

        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = var.approved_role_arns
          }
        }
      },
      {
        Sid       = "DenyOtherListingPrincipals"
        Effect    = "Deny"
        Principal = "*"

        Action = [
          "s3:ListBucket",
          "s3:ListBucketVersions"
        ]

        Resource = local.bucket_arn

        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = var.approved_role_arns
          }
        }
      }
    ]
  })
}
