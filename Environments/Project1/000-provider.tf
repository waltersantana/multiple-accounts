############################
#   Author: Walter Santana #
#  Created: 11-11-2022     #  
# Modified: 10-12-2022     #
############################

terraform {
  required_version = ">= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.13.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "default"

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/Administrator"
  }

  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias   = "Root"
  region  = local.region
  profile = var.accounts.Root.profile
  default_tags {
    tags = local.tags
  }
}

provider "null" {
  # Configuration options
}

locals {
  region = var.aws_region
  abbr   = var.project["abbr"]
  tags = {
    Provisoned = "Terraform",
    Owner      = "DevOps Team",
    Project    = var.project["name"]
  }

  bucket_name         = "${terraform.workspace}.${var.project["abbr"]}.${var.tf_s3_name}"
  dynamodb_table_name = "${terraform.workspace}-${var.project["abbr"]}-${var.tf_dynamodb_table}"
  cluster_name        = "${local.abbr}-${var.cluster_name}"
  child_zone          = "${terraform.workspace}.${var.root_zone}"
}