############################
#   Author: Walter Santana #
#  Created: 11-11-2022     #  
# Modified: 10-01-2023     #
############################

terraform {
  required_version = ">= 1.1.9"
  # backend "s3" {
  #   bucket         = "net.healthsafe.co.nz" ##TODO: Change to the real domain
  #   key            = "net/aws_infra_state"
  #   region         = "ap-southeast-2"
  #   dynamodb_table = "net-terraform-locks"
  #   encrypt        = true
  #   profile        = "Administrator@Networking"
  # }

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
  alias   = "Networking"
  region  = local.region
  profile = var.accounts.Networking.profile
  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias   = "Production"
  region  = local.region
  profile = var.accounts.Production.profile
  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias   = "Devops"
  region  = local.region
  profile = var.accounts.DevOps.profile
  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias   = "QualityAssurance"
  region  = local.region
  profile = var.accounts.QualityAssurance.profile
  default_tags {
    tags = local.tags
  }
}

locals {
  region = "ap-southeast-2"
  abbr   = var.project["abbr"]
  tags = {
    Provisoned = "Terraform"
    Owner      = "DevOps Team"
    Project    = var.project["name"]
  }
}

provider "null" {
  # Configuration options
}

locals {
  bucket_name         = "${local.abbr}.${var.tf_s3_name}"
  dynamodb_table_name = "${local.abbr}-${var.tf_dynamodb_table}"
}