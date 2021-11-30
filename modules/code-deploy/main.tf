resource "aws_codedeploy_app" "main" {
  compute_platform = "ECS"
  name             = var.name
  tags = {
    "Name" = var.name
  }
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_config_name = var.deployment_config_name
  deployment_group_name  = aws_codedeploy_app.main.name
  service_role_arn       = aws_iam_role.codedeploy.arn

  auto_rollback_configuration {
    enabled = var.auto_rollback_enabled
    events  = var.auto_rollback_events
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = var.deployment_ready_option_action_on_timeout
      wait_time_in_minutes = var.deployment_ready_option_action_on_timeout == "STOP_DEPLOYMENT" ? var.deployment_ready_option_wait_time_in_minutes : 0
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.deployment_termination_wait_time_in_minutes
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  # You can configure the Load Balancer to use in a deployment.
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.load_balancer_production_listener_arn]
      }

      # One pair of target groups. One is associated with the original task set.
      # The second target is associated with the task set that serves traffic after the deployment completes.
      dynamic "target_group" {
        for_each = var.load_balancer_target_group_names
        content {
          name = target_group.value
        }
      }
    }
  }
}
