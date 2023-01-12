############################
#   Author: Walter Santana #
#  Created: 11-11-2023     #  
# Modified: 10-01-2023     #
############################

resource "aws_s3_bucket" "s3_terraform" {
  bucket        = local.bucket_name
  force_destroy = true
  lifecycle {
    # Any Terraform plan that includes a destroy of this resource will
    # result in an error message.
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "s3_terraform" {
  bucket = aws_s3_bucket.s3_terraform.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_s3_terraform" {
  bucket = aws_s3_bucket.s3_terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_SSE" {
  bucket = aws_s3_bucket.s3_terraform.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_terraform_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "s3_terraform_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}