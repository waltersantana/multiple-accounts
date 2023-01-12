resource "aws_alb" "main" {
  name            = "${local.abbr}-alb"
  internal        = true
  subnets         = var.private_subnets
  security_groups = [aws_security_group.alb.id]
}

resource "aws_alb_target_group" "shared_app" {
  for_each = { for each in var.apps : each.abbr => each }

  name                 = "${local.abbr}-${each.value.abbr}-tgr"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/${each.value.abbr}/${each.value.health_check_path}"
    unhealthy_threshold = "2"
  }
  tags = {
    Name = "${each.value.abbr}-alb"
  }
}

# Redirect all traffic from the ALB to the target group

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "back_end" {
  load_balancer_arn = aws_alb.main.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.issued.arn


  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "HS Services Not Implemented"
      status_code  = "501"
    }
  }
}

resource "aws_lb_listener_rule" "static" {
  for_each     = { for each in var.apps : each.abbr => each }
  listener_arn = aws_alb_listener.back_end.arn
  #priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.shared_app[each.value.abbr].id
  }

  condition {
    path_pattern {
      values = ["/${each.value.abbr}", "/${each.value.abbr}/*"]
    }

  }
}