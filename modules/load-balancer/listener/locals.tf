locals {

  # blue-tg identification
  blue_id = "blue"

  # green-tg identification
  green_id = "green"

  # canary tg groups
  target_groups = {
    for tgs in [local.blue_id, local.green_id] :
    tgs => merge({
      name             = "${tgs}-${var.name}-${var.container_port}"
      backend_protocol = "HTTP"
      backend_port     = var.container_port
      target_type      = "ip"
      health_check     = lookup(var.load_balancer, "health_check", null)
    }, lookup(var.load_balancer, "target_group_additional_options", {}))
  }

  listener_test_configuration = {
    "main" : {
      load_balancer_arn = var.load_balancer.alb_arn
      certificate_arn   = var.load_balancer.testing_listener.certificate_arn != "" ? var.load_balancer.testing_listener.certificate_arn : null
      ssl_policy        = var.load_balancer.testing_listener.ssl_policy != "" ? var.load_balancer.testing_listener.ssl_policy : null
      protocol          = var.load_balancer.testing_listener.protocol != "" ? var.load_balancer.testing_listener.protocol : "HTTP"
      port              = var.load_balancer.testing_listener.port > 0 ? var.load_balancer.testing_listener.port : 8443
    }
  }
}