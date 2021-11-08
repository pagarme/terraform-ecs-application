resource "aws_lb_target_group" "main" {
  for_each = to_set(["blue", "green"])

  name = "${var.name}-${each.key}"

  vpc_id      = var.vpc_id
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    healthy_threshold   = var.health_check.healthy_threshold
    interval            = var.health_check.interval
    matcher             = var.health_check.matcher
    path                = var.health_check.path
    protocol            = var.health_check.protocol
    timeout             = var.health_check.timeout
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }

  lifecycle {
    create_before_destroy = true
  }
}
