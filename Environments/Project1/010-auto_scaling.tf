resource "aws_appautoscaling_target" "target" {
  for_each = { for each in var.apps : each.abbr => each }

  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.shared_main.name}/${aws_ecs_service.shared_main[each.value.abbr].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  #role_arn           = aws_iam_role.ecs_auto_scale_role.arn
  min_capacity = 1
  max_capacity = 6
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "up" {
  for_each = { for each in var.apps : each.abbr => each }

  name               = "${local.abbr}_${each.value.abbr}_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.shared_main.name}/${aws_ecs_service.shared_main[each.value.abbr].name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "down" {
  for_each = { for each in var.apps : each.abbr => each }

  name               = "${local.abbr}_${each.value.abbr}_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.shared_main.name}/${aws_ecs_service.shared_main[each.value.abbr].name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  for_each = { for each in var.apps : each.abbr => each }

  alarm_name          = "${local.abbr}_${each.value.abbr}_cb_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.shared_main.name
    ServiceName = "${aws_ecs_service.shared_main[each.value.abbr].name}"
  }

  alarm_actions = [aws_appautoscaling_policy.up[each.value.abbr].arn]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  for_each = { for each in var.apps : each.abbr => each }

  alarm_name          = "${local.abbr}_${each.value.abbr}_cb_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.shared_main.name
    ServiceName = "${aws_ecs_service.shared_main[each.value.abbr].name}"
  }

  alarm_actions = [aws_appautoscaling_policy.down[each.value.abbr].arn]

}