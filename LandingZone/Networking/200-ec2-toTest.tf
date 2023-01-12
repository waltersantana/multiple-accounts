############################
#   Author: Walter Santana #
#  Created: 22-11-2022     #  
# Modified: 10-12-2022     #
############################

# NOTES
## Deploy ec2's on the all vpcs
## Deploy 1 ec2 on first public subnets (prd)
## Deploy others ec2's on first private subnets of all the rest envs

# TODO: Normalize the code with for-each meta argument or similar 

# --------------------- #
# EC2 Instances Section #
# --------------------- #

resource "tls_private_key" "oskey" {
  algorithm = "RSA"
}

resource "local_file" "myterrakey" {
  content  = tls_private_key.oskey.private_key_pem
  filename = "all-envs.pem"
}

resource "aws_key_pair" "test-tgw-keypair" {
  provider   = aws.Networking
  key_name   = "all-envs"
  public_key = tls_private_key.oskey.public_key_openssh
}

# Security Groups
## Need to create 4 of them as our Security Groups are linked to a VPC

resource "aws_security_group" "sec-group-vpc-ssh-icmp" {
  provider = aws.Networking
  for_each = { for each in var.environments : each.abbr => each }

  name        = "sec-group-vpc-prd-ssh-icmp"
  description = "test-tgw: Allow SSH and ICMP traffic"
  vpc_id      = module.vpc[each.key].vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sec-group-vpc-prd-ssh-icmp"
  }
}

# VMs

## Fetching AMI info
data "aws_ami" "ubuntu" {
  provider    = aws.Networking
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20221103.3-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_instance" "test-tgw-instance" {
  provider = aws.Networking
  for_each = { for each in var.environments : each.abbr => each }

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = each.value.abbr == var.accounts.Production.abbr ? module.vpc[each.key].public_subnets[0] : module.vpc[each.key].private_subnets[0]
  vpc_security_group_ids = ["${aws_security_group.sec-group-vpc-ssh-icmp[each.key].id}"]
  key_name               = aws_key_pair.test-tgw-keypair.key_name
  #private_ip             = "10.0.100.100"
  #private_ip = cidrhost("10.1.2.240/28", 1)
  tags = {
    Name = "${each.value.abbr}-pub"

  }
}

# ------- #
# Outputs #
# ------- #

# output "test_private_ip" {
#   value = [
#     for test_instance in aws_instance.test-tgw-instance : test_instance.private_ip
#   ]
# }
# output "test_public_ip" {
#   value = aws_instance.test-tgw-instance[var.accounts.Production.abbr].public_ip
# }