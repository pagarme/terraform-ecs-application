# Terraform module which creates CodeDeploy for ECS resources on AWS.
#
# https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html

# https://www.terraform.io/docs/providers/aws/r/codedeploy_app.html
resource "aws_codedeploy_app" "this" {
  for_each = local.deployment_configuration

  compute_platform = "ECS"
  name             = each.value.name

  tags = merge(
    {
      "Name" = each.value.name
    },
    var.tags,
  )
}

# https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_group.html
resource "aws_codedeploy_deployment_group" "this" {
  for_each = local.deployment_configuration

  app_name               = aws_codedeploy_app.this[each.key].name
  deployment_group_name  = each.value.name
  service_role_arn       = aws_iam_role.codedeploy[each.key].arn
  deployment_config_name = each.value.deployment_config_name

  # You can configure a deployment group or deployment to automatically roll back when a deployment fails or when a
  # monitoring threshold you specify is met. In this case, the last known good version of an application revision is deployed.
  # https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-groups-configure-advanced-options.html
  auto_rollback_configuration {
    # If you enable automatic rollback, you must specify at least one event type.
    enabled = each.value.auto_rollback_enabled

    # The event type or types that trigger a rollback. Supported types are DEPLOYMENT_FAILURE and DEPLOYMENT_STOP_ON_ALARM.
    events = each.value.auto_rollback_events
  }

  # You can configure options for a blue/green deployment.
  # https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_BlueGreenDeploymentConfiguration.html
  blue_green_deployment_config {
    # Information about how traffic is rerouted to instances in a replacement environment in a blue/green deployment.
    deployment_ready_option {
      # Information about when to reroute traffic from an original environment to a replacement environment in a blue/green deployment.
      #
      # - CONTINUE_DEPLOYMENT: Register new instances with the load balancer immediately after the new application
      #                        revision is installed on the instances in the replacement environment.
      # - STOP_DEPLOYMENT: Do not register new instances with a load balancer unless traffic rerouting is started
      #                    using ContinueDeployment. If traffic rerouting is not started before the end of the specified
      #                    wait period, the deployment status is changed to Stopped.
      action_on_timeout = each.value.action_on_timeout

      # The number of minutes to wait before the status of a blue/green deployment is changed to Stopped
      # if rerouting is not started manually. Applies only to the STOP_DEPLOYMENT option for action_on_timeout.
      # Can not be set to STOP_DEPLOYMENT when timeout is set to 0 minutes.
      wait_time_in_minutes = each.value.wait_time_in_minutes
    }

    # You can configure how instances in the original environment are terminated when a blue/green deployment is successful.
    terminate_blue_instances_on_deployment_success {
      # Valid values are TERMINATE or KEEP_ALIVE.
      # If specified TERMINATE, then instances are terminated after a specified wait time.
      # On the other hand, if specified KEEP_ALIVE, then occurred an unknown error when terraform apply.
      action = "TERMINATE"

      # The number of minutes to wait after a successful blue/green deployment before terminating instances
      # from the original environment. The maximum setting is 2880 minutes (2 days).
      termination_wait_time_in_minutes = each.value.termination_wait_time_in_minutes
    }
  }

  # For ECS deployment, the deployment type must be BLUE_GREEN, and deployment option must be WITH_TRAFFIC_CONTROL.
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  # Configuration block(s) of the ECS services for a deployment group.
  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.name
  }

  # You can configure the Load Balancer to use in a deployment.
  load_balancer_info {
    # Information about two target groups and how traffic routes during an Amazon ECS deployment.
    # An optional test traffic route can be specified.
    # https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_TargetGroupPairInfo.html
    target_group_pair_info {
      # The path used by a load balancer to route production traffic when an Amazon ECS deployment is complete.
      prod_traffic_route {
        listener_arns = compact([var.production_listener_arn])
      }

      # One pair of target groups. One is associated with the original task set.
      # The second target is associated with the task set that serves traffic after the deployment completes.
      dynamic "target_group" {
        for_each = var.target_groups
        content {
          name = target_group.value.name
        }
      }
    }
  }

  tags = var.tags
}
