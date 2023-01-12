############################
#   Author: Walter Santana #
#  Created: 22-11-2022     #  
# Modified: 09-12-2022     #
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

# # 1) GENERAL
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

# 2) CONDITIONALS
variable "prd_abbr" {
  type    = string
  default = "default"
}

variable "envs_cir_blocks" {
  type    = string
  default = "default"
}

# 5) ENVIRONMENTS
variable "environments" {
  type = list(object({
    #GENERAL
    abbr        = string
    name        = string
    environment = string

    #VPN
    client_cidr_block          = string
    server_certificate_arn     = string
    root_certificate_chain_arn = string

    #VPC
    vpc_name         = string
    vpc_cidr         = string
    default_vpc_name = string

    public_subnets   = list(string)
    private_subnets  = list(string)
    database_subnets = list(string)

    enable_vpn_gateway = bool

    enable_nat_gateway     = bool
    single_nat_gateway     = bool
    one_nat_gateway_per_az = bool

    enable_dhcp_options            = bool
    enable_classiclink             = bool
    enable_classiclink_dns_support = bool

    enable_dns_hostnames = bool
    enable_dns_support   = bool

    instance_tenancy = string



  }))
}