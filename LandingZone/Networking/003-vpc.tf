############################
#   Author: Walter Santana #
#  Created: 11-11-2022     #  
# Modified: 22-11-2022     #
############################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.18.0"

  for_each         = { for each in var.environments : each.abbr => each }
  name             = each.value.vpc_name
  cidr             = each.value.vpc_cidr
  default_vpc_name = each.value.default_vpc_name

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets  = each.value.private_subnets
  public_subnets   = each.value.public_subnets
  database_subnets = each.value.database_subnets

  #create_database_subnet_group = true
  #database_subnet_group_name   = "${local.vpc_name}-db-subnet-group"
  #database_subnet_group_tags   = local.tags

  # manage_default_network_acl = true
  # default_network_acl_tags   = { Name = "${local.vpc_name}-acl-default" }

  # manage_default_route_table = true
  # default_route_table_tags   = { Name = "${local.vpc_name}-route-table-default" }

  # manage_default_security_group = true
  # default_security_group_tags   = { Name = "${var.vpc_name}-security-group-default" }

  enable_vpn_gateway = each.value.enable_vpn_gateway

  enable_nat_gateway     = each.value.enable_nat_gateway
  single_nat_gateway     = each.value.single_nat_gateway
  one_nat_gateway_per_az = each.value.one_nat_gateway_per_az

  # reuse_nat_ips          = true # <= Skip creation of EIPs for the NAT Gateways
  # external_nat_ip_ids    = aws_eip.nat.*.id # <= IPs specified here as input to the module

  enable_dhcp_options            = each.value.enable_dhcp_options
  enable_classiclink             = each.value.enable_classiclink
  enable_classiclink_dns_support = each.value.enable_classiclink_dns_support

  enable_dns_hostnames = each.value.enable_dns_hostnames #EKS - Private Cliuster - Requirement
  enable_dns_support   = each.value.enable_dns_support   #EKS - Private Cliuster - Requirement

  instance_tenancy = each.value.instance_tenancy

}