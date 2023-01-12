resource "aws_ecr_repository" "ecr_repository" {
  for_each = { for each in var.apps : each.abbr => each }

  name                 = "${local.abbr}-${each.value.repository}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = { Name = "${local.abbr}-${each.value.repository}" }
}