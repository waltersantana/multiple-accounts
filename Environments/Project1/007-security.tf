locals {
  docdb_name = "${local.abbr}-${var.docdb_name}"
}

# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "alb" {
  name        = "${local.abbr}-alb-sgr"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = flatten([for v in var.apps : [v.appPort]])
    content {
      description = "ECS Service ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.abbr}-alb-sgr"
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "shared_ecs_tasks" {
  for_each = { for each in var.apps : each.abbr => each }

  name        = "${each.value.abbr}-ecs-tsk-sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = each.value.appPort
    to_port         = each.value.appPort
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.abbr}-${each.value.abbr}-ecs-tsk-sgr"
  }
}

#DocumentDB
resource "aws_security_group" "shared_service" {
  name   = "${local.docdb_name}-sgr"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.docdb_name}-sgr"
  }
}