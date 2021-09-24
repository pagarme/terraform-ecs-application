#                            ▄▄▄▄▄
#                           ▐▓▓▓▓▓▓▓▓▓▓▓▄▄
#                           ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄▄
#                           ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
#                           ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
#                           ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
#                               ▀▀▀▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
#                                      ▀▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
#                                          ▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
#                                             ▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
#                                               ▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓
#                                                 ▓▓▓▓▓▓▓▓▓▓▓▓▓▓
#                      ▄▄▓▓▓▓▓▓▓▄▄                 ▀▓▓▓▓▓▓▓▓▓▓▓▓▌
#                  ▄▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄               ▀▓▓▓▓▓▓▓▓▓▓▓▓▌
#                 ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌              ▓▓▓▓▓▓▓▓▓▓▓▓▓
#               ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓             ▐▓▓▓▓▓▓▓▓▓▓▓▓▌
#               ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓             ▓▓▓▓▓▓▓▓▓▓▓▓▌
#              ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌            ▓▓▓▓▓▓▓▓▓▓▓▓▓
#              ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
#               ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
#               ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
#                 ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
#                   ▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
#                      ▀▀▀▓▓▓▓▓▀▀▀
# Pagar.me pagamentos, uma empresa do grupo Stone.

resource "aws_ecs_service" "main" {
  name    = var.name
  cluster = var.ecs_cluster_arn

  launch_type      = local.ecs_service_launch_type
  platform_version = local.fargate_platform_version

  # Use latest active revision
  task_definition = "${aws_ecs_task_definition.main.family}:${max(
    aws_ecs_task_definition.main.revision,
    data.aws_ecs_task_definition.main.revision,
  )}"

  desired_count                      = var.tasks_desired_count
  deployment_minimum_healthy_percent = var.tasks_minimum_healthy_percent
  deployment_maximum_percent         = var.tasks_maximum_percent

  deployment_controller {
    type = var.deployment_controller
  }

  dynamic "ordered_placement_strategy" {
    for_each = local.ecs_service_ordered_placement_strategy[local.ecs_service_launch_type]

    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  dynamic "placement_constraints" {
    for_each = local.ecs_service_placement_constraints[local.ecs_service_launch_type]

    content {
      type = placement_constraints.value.type
    }
  }

  network_configuration {
    subnets          = var.networking.subnet_ids
    assign_public_ip = var.networking.assign_public_ip
    security_groups  = local.ecs_service_security_groups
  }

  dynamic "load_balancer" {
    for_each = local.production_target_groups
    content {
      container_name   = var.load_balancer.container_name != null ? var.load_balancer.container_name : aws_lb_target_group.this[load_balancer.key].name
      target_group_arn = aws_lb_target_group.this[load_balancer.key].arn
      container_port   = load_balancer.value.backend_port
    }
  }


  health_check_grace_period_seconds = var.load_balancer.alb_arn != null ? var.load_balancer.health_check_grace_period_seconds : null

  dynamic "service_registries" {
    for_each = var.service_registries
    content {
      registry_arn   = service_registries.value.registry_arn
      container_name = service_registries.value.container_name
      container_port = service_registries.value.container_port
      port           = service_registries.value.port
    }
  }

  tags = var.tags

  depends_on = [
    aws_lb_target_group.this,
    aws_lb_listener_rule.this
  ]

  lifecycle {
    ignore_changes = [
      load_balancer,
      platform_version,
      task_definition # for code deploy tasks
    ]
  }
}
