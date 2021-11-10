resource "aws_lb_target_group" "main" {
  for_each = ["blue", "green"]

  name = "${var.name}-${each.key}"

  vpc_id      = var.load_balancer_target_groups_vpc_id
  port        = var.load_balancer_target_groups_port
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    healthy_threshold   = var.load_balancer_target_groups_health_check_healthy_threshold
    interval            = var.load_balancer_target_groups_health_check_interval
    matcher             = var.load_balancer_target_groups_health_check_matcher
    path                = var.load_balancer_target_groups_health_check_path
    protocol            = var.load_balancer_target_groups_health_check_protocol
    timeout             = var.load_balancer_target_groups_health_check_timeout
    unhealthy_threshold = var.load_balancer_target_groups_health_check_unhealthy_threshold
  }

  lifecycle {
    create_before_destroy = true
  }
}
