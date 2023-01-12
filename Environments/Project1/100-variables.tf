############################
#   Author: Walter Santana #
#  Created: 11-11-2022     #  
# Modified: 22-12-2022     #
############################

variable "aws_account_id" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "aws_account_name" {
  type = string
}
variable "aws_account_abbr" {
  type = string
}


# 1) GENERAL
variable "accounts" {
  type = map(
    object({
      name    = string,
      abbr    = string,
      profile = string,
      number  = string
    })
  )
}

variable "project" {
  type = map(any)
  default = {
    abbr = "def"
  name = "Default" }
}

# variable "azs" {
#   type = list(string)
# }

# 2) S3 TERRAFROM STATE
variable "tf_s3_name" {
  type    = string
  default = "default"
}

# 3) DYNAMODB TERRAFORM LOCK
variable "tf_dynamodb_table" {
  type    = string
  default = "default"
}

# 3) VPC
variable "vpc_id" {
  type    = string
  default = "default"
}

# 4) SUBNETS
variable "private_subnets" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}

variable "database_subnets" {
  type = list(string)
}

# 5) ECR
variable "ecr_names" {
  type    = list(string)
  default = []
}

# 6) CLUSTER ECS
variable "cluster_name" {
  description = "ECS Fargate Cluster Name"
  type        = string
  default     = "default"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "EcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role Name"
  default     = "myEcsAutoScaleRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "3"
}

# 7) DOCUMENTDB
variable "docdb_name" {
  description = "Documend db Database"
  default     = "default"
}

variable "docdb_instance_class" {
  default = "db.t3.medium"
}

# # 8) CONTAINERS
variable "apps" {
  type = list(object({
    abbr              = string,
    name              = string,
    count             = string,
    repository        = string,
    image             = string,
    containerPort     = string,
    appPort           = string,
    fargate_cpu       = string,
    fargate_memory    = string,
    health_check_path = string
    })
  )
}

# 6) DNS
variable "root_zone" {
  description = ""
  type        = string
  default     = "default"
}

variable "child_zone" {
  description = ""
  type        = string
  default     = "default"
}

# 7) VPN
variable "client_cidr_block" {
  type    = string
  default = "default"
}
