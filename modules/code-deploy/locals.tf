locals {
  deployment_configuration = {
    "main" : {
      name                             = var.name
      description                      = var.deployment.description
      deployment_config_name           = var.deployment.deployment_config_name
      auto_rollback_enabled            = var.deployment.auto_rollback_enabled
      auto_rollback_events             = var.deployment.auto_rollback_events
      action_on_timeout                = var.deployment.action_on_timeout
      wait_time_in_minutes             = var.deployment.wait_time_in_minutes
      termination_wait_time_in_minutes = var.deployment.termination_wait_time_in_minutes
    }
  }

  iam_name = "${var.name}-ecs-codedeploy"
}