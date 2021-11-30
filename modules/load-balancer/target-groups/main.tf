resource "aws_lb_target_group" "main" {
  for_each = toset(["blue", "green"])

  name = "${var.name}-${each.key}"

  vpc_id      = var.vpc_id
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  lifecycle {
    create_before_destroy = true
  }
}
