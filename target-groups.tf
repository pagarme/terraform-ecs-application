resource "aws_lb_target_group" "this" {
  for_each = local.target_groups


  name        = lookup(each.value, "name", null)
  name_prefix = lookup(each.value, "name_prefix", null)


  vpc_id           = var.networking.vpc_id
  port             = lookup(each.value, "backend_port", null)
  protocol         = lookup(each.value, "backend_protocol", null)
  protocol_version = lookup(each.value, "protocol_version", null)
  target_type      = lookup(each.value, "target_type", null)

  deregistration_delay               = lookup(each.value, "deregistration_delay", null)
  slow_start                         = lookup(each.value, "slow_start", null)
  proxy_protocol_v2                  = lookup(each.value, "proxy_protocol_v2", false)
  lambda_multi_value_headers_enabled = lookup(each.value, "lambda_multi_value_headers_enabled", false)
  load_balancing_algorithm_type      = lookup(each.value, "load_balancing_algorithm_type", null)

  dynamic "health_check" {
    for_each = length(keys(lookup(each.value, "health_check", {}))) == 0 ? [] : [lookup(each.value, "health_check", {})]

    content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      timeout             = lookup(health_check.value, "timeout", null)
      protocol            = lookup(health_check.value, "protocol", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }

  dynamic "stickiness" {
    for_each = length(keys(lookup(each.value, "stickiness", {}))) == 0 ? [] : [lookup(each.value, "stickiness", {})]

    content {
      enabled         = lookup(stickiness.value, "enabled", null)
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      type            = lookup(stickiness.value, "type", null)
    }
  }

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {}),
    {
      "Name" = lookup(each.value, "name", lookup(each.value, "name_prefix", ""))
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "default_role" {
  for_each = local.listener_default_configuration

  listener_arn = each.value.listener_arn

  action {
    order            = 10
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[local.blue_id].arn
  }

  condition {
    host_header {
      values = ["*.*"]
    }
  }

  lifecycle {
    ignore_changes = [
      action
    ]
  }
}

resource "aws_lb_listener" "testing_route" {
  for_each = local.listener_test_configuration

  load_balancer_arn = each.value.load_balancer_arn
  certificate_arn   = each.value.certificate_arn
  port              = each.value.port

  # this action is coded to 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[local.green_id].arn
  }

  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}



