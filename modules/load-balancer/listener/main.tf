resource "aws_lb_listener" "testing_route" {
  for_each = local.listener_test_configuration

  load_balancer_arn = each.value.load_balancer_arn
  certificate_arn   = each.value.certificate_arn
  ssl_policy        = each.value.ssl_policy
  port              = each.value.port
  protocol          = each.value.protocol

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


