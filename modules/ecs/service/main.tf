resource "aws_ecs_service" "main" {
  name    = var.name
  cluster = var.ecs_cluster_arn

  launch_type      = var.launch_type
  platform_version = var.launch_type == "FARGATE" ? var.platform_version : null

  task_definition = aws_ecs_task_definition.main.arn

  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  deployment_controller {
    type = var.deployment_controller_type
  }

  dynamic "ordered_placement_strategy" {
    for_each = local.ordered_placement_strategy[var.launch_type]

    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  dynamic "placement_constraints" {
    for_each = local.placement_constraints[var.launch_type]

    content {
      type = placement_constraints.value.type
    }
  }

  network_configuration {
    subnets          = var.network_subnets
    assign_public_ip = var.network_assign_public_ip
    security_groups  = [aws_security_group.main.id]
  }

  load_balancer {
    container_name   = var.load_balancer_container_name
    target_group_arn = var.load_balancer_target_group_arn
    container_port   = local.container_port
  }

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}
