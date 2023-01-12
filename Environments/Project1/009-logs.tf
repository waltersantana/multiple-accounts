# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "shared_cb_log_group" {
  for_each = { for each in var.apps : each.abbr => each }

  name              = "/ecs/${each.value.abbr}-app"
  retention_in_days = 30

  tags = {
    Name = "${local.abbr}-lgr"
  }
}

resource "aws_cloudwatch_log_stream" "shared_cb_log_stream" {
  for_each = { for each in var.apps : each.abbr => each }

  name           = "${each.value.abbr}-lst"
  log_group_name = aws_cloudwatch_log_group.shared_cb_log_group[each.value.abbr].name
}