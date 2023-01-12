############################
#   Author: Walter Santana #
#  Created: 22-11-2022     #  
# Modified: 15-12-2022     #
############################


# NOTES:
## Configured to deploy prd and qua environment
## VPN association on the first private subnet of prd or qua vpc
## Certificates has to be deployed manually on AWS
## Certificates are for testing

resource "aws_acm_certificate" "vpn_client_root" {
  private_key       = file("certs/client1.domain.tld.key")
  certificate_body  = file("certs/client1.domain.tld.crt")
  certificate_chain = file("certs/ca.crt")
}

resource "aws_security_group" "vpn_access" {
  for_each = { for each in var.environments : each.abbr => each }

  vpc_id = module.vpc[each.key].vpc_id
  name   = "vpn-${each.value.abbr}-sgr"

  ingress {
    from_port = 443
    protocol  = "UDP"
    to_port   = 443
    cidr_blocks = [
    "0.0.0.0/0"]
    description = "Incoming VPN connection"
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [
    "0.0.0.0/0"]
  }

}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  for_each = { for each in var.environments : each.abbr => each }

  description            = "Client VPN ${each.value.name}"
  client_cidr_block      = each.value.client_cidr_block
  split_tunnel           = true
  server_certificate_arn = each.value.server_certificate_arn
  vpc_id                 = module.vpc[each.key].vpc_id
  security_group_ids     = [aws_security_group.vpn_access[each.key].id]
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = each.value.root_certificate_chain_arn
  }

  connection_log_options {
    enabled = false
  }

  tags = merge(local.tags, {
    Name = "vpn-${each.key}-endpoint"
  })
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnets" {
  for_each = { for each in var.environments : each.abbr => each }


  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn[each.key].id
  subnet_id              = module.vpc[each.key].private_subnets[0]
  #security_groups = [aws_security_group.vpn_access.id]

  lifecycle {
    // The issue why we are ignoring changes is that on every change
    // terraform screws up most of the vpn assosciations
    // see: https://github.com/hashicorp/terraform-provider-aws/issues/14717
    ignore_changes = [subnet_id]
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  for_each = { for each in var.environments : each.abbr => each }

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn[each.key].id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}