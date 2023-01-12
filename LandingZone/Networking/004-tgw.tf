
############################
#   Author: Walter Santana #
#  Created: 11-11-2022     #  
# Modified: 09-11-2022     #
############################


###########################
# Transit Gateway Section #
###########################

# Transit Gateway
## Default association and propagation are enable since our scenario involves
## a more elaborated setup where
## - VPCs can reach all VPCs
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway with all VPCs, 3 subnets each"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = merge(local.tags, { Name = "tgw-internet" })
}

# VPC attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-general" {
  for_each           = { for each in var.environments : each.abbr => each }
  subnet_ids         = module.vpc[each.key].private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.vpc[each.key].vpc_id

  tags = merge(local.tags, { Name = "tgw-att-${each.key}" })
}

# Transit Gateway Routes
resource "aws_ec2_transit_gateway_route" "default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-general["prd"].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}

# Addittional Routes
resource "aws_route" "rtb-route" {
  for_each               = { for each in var.environments : each.abbr => each }
  route_table_id         = each.key == var.prd_abbr ? module.vpc[each.key].public_route_table_ids[0] : module.vpc[each.key].private_route_table_ids[0]
  destination_cidr_block = each.key == var.prd_abbr ? var.envs_cir_blocks : "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway.tgw]
}