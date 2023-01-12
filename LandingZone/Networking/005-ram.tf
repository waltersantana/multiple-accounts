############################
#   Author: Walter Santana #
#  Created: 11-11-2022     #  
# Modified: 10-11-2022     #
############################

# NOTE: Temporary resources to use in the aws_ram_resource_association
locals {
  public_subnets_aux = flatten([
    for env in var.environments : [
      for public_subnet in env.public_subnets : {
        abbr  = env.abbr
        index = index(env.public_subnets, public_subnet)
      }
    ]
  ])
  private_subnets_aux = flatten([
    for env in var.environments : [
      for private_subnet in env.private_subnets : {
        abbr  = env.abbr
        index = index(env.private_subnets, private_subnet)
      }
    ]
  ])
  database_subnets_aux = flatten([
    for env in var.environments : [
      for database_subnet in env.database_subnets : {
        abbr  = env.abbr
        index = index(env.database_subnets, database_subnet)
      }
    ]
  ])

}

resource "aws_ram_resource_share" "ram_resource_share" {
  for_each = { for each in var.accounts : each.abbr => each if each.abbr != "net" }

  name                      = "${each.value.name}-Subnets"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "ram_ppal_assoc" {
  for_each = { for each in var.accounts : each.abbr => each if each.abbr != "net" }

  principal          = each.value.number
  resource_share_arn = aws_ram_resource_share.ram_resource_share[each.value.abbr].arn
}

resource "aws_ram_resource_association" "public_subnet" {
  count = length(local.public_subnets_aux)

  resource_arn       = module.vpc["${local.public_subnets_aux[count.index].abbr}"].public_subnet_arns["${local.public_subnets_aux[count.index].index}"]
  resource_share_arn = aws_ram_resource_share.ram_resource_share["${local.public_subnets_aux[count.index].abbr}"].arn
}

resource "aws_ram_resource_association" "private_subnet" {
  count = length(local.private_subnets_aux)

  resource_arn       = module.vpc["${local.private_subnets_aux[count.index].abbr}"].private_subnet_arns["${local.private_subnets_aux[count.index].index}"]
  resource_share_arn = aws_ram_resource_share.ram_resource_share["${local.private_subnets_aux[count.index].abbr}"].arn
}

resource "aws_ram_resource_association" "database_subnet" {
  count = length(local.database_subnets_aux)

  resource_arn       = module.vpc["${local.database_subnets_aux[count.index].abbr}"].database_subnet_arns["${local.database_subnets_aux[count.index].index}"]
  resource_share_arn = aws_ram_resource_share.ram_resource_share["${local.database_subnets_aux[count.index].abbr}"].arn
}