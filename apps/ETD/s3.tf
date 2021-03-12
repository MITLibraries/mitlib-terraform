module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "thesis-submit"
}

# Create the bucket with CORS, Versioning, and Lifecycle
resource "aws_s3_bucket" "default" {
  bucket = "${var.bucketname}-${terraform.workspace}"
  acl    = var.s3_acl

  dynamic "cors_rule" {
    for_each = var.s3_cors_rule

    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }

  versioning {
    enabled    = var.versioning_enabled
    mfa_delete = var.mfadelete_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "${module.label.name}-transfer-to-IA"
    enabled = var.standard_transition_enabled

    transition {
      days          = var.standard_transition_days
      storage_class = "STANDARD_IA"
    }
  }

  lifecycle_rule {
    id      = "${module.label.name}-transfer-to-glacier"
    enabled = var.glacier_transition_enabled

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }
  }

  lifecycle_rule {
    id      = "${module.label.name}-expire-object"
    enabled = var.expire_objects_enabled

    expiration {
      days = var.expiration_days
    }
  }

  lifecycle_rule {
    id      = "${module.label.name}-noncurrent-rules"
    enabled = var.noncurrent_rules_enabled

    noncurrent_version_expiration {
      days = var.noncurrent_version_expiration_days
    }

    noncurrent_version_transition {
      days          = var.noncurrent_version_transition_days
      storage_class = "GLACIER"
    }
  }

  tags = module.label.tags

}

# Create the IAM user for access to bucket
resource "aws_iam_user" "default" {
  name          = "${module.label.name}-readwrite"
  path          = "/"
  force_destroy = "false"
  tags          = module.label.tags
}

# Create the key/secret pair for the IAM user
resource "aws_iam_access_key" "default" {
  user = aws_iam_user.default.name
}

# Create the simple IAM policy document for read/write access to the bucket
data "aws_iam_policy_document" "readwrite" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.default.arn, "${aws_s3_bucket.default.arn}/*"]
    effect    = "Allow"
  }
}

# Create the IAM policy itself (the JSON that AWS uses)
resource "aws_iam_policy" "readwrite" {
  name        = "${module.label.name}-readwrite"
  description = "Policy to allow IAM user read/write access to ${module.label.name} S3 bucket"
  policy      = data.aws_iam_policy_document.readwrite.json
}

# Attach the new IAM policy to the new IAM user
resource "aws_iam_user_policy_attachment" "default_rw" {
  user       = aws_iam_user.default.name
  policy_arn = aws_iam_policy.readwrite.arn
}