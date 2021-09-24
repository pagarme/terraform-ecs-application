locals {
  ecs_service_launch_type  = var.ecs_use_fargate ? "FARGATE" : "EC2"
  fargate_platform_version = var.ecs_use_fargate ? var.fargate_options.platform_version : null

  ecs_service_ordered_placement_strategy = {
    EC2 = [
      {
        type  = "spread"
        field = "attribute:ecs.availability-zone"
      },
      {
        type  = "spread"
        field = "instanceId"
      },
    ]
    FARGATE = []
  }

  ecs_service_placement_constraints = {
    EC2 = [
      {
        type = "distinctInstance"
      },
    ]
    FARGATE = []
  }

  ecs_service_security_groups = setunion([aws_security_group.ecs_sg.id], var.additional_security_group_ids)

  # blue-tg identification
  blue_id = "blue"

  production_target_groups = var.load_balancer != null ? {
    for tgs in [local.blue_id] :
    tgs => merge({
      name             = "${tgs}-${var.name}-${var.container_port}"
      backend_protocol = "HTTP"
      backend_port     = var.container_port
      target_type      = "ip"
      health_check     = lookup(var.load_balancer, "health_check", null)
    }, lookup(var.load_balancer, "target_group_additional_options", {}))
  } : {}
}