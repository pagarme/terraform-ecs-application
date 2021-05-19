locals {
  # name of the service
  name                  = "${var.name}-${var.environment}"
  target_container_name = local.name
  # log-group
  awslogs_group = "${var.cloudwatch.prefix_name}/${var.name}"
  # kms configuration 
  kms_key_id = var.kms_key_id == "" ? null : var.kms_key_id


  # iam 
  iam_name = "${var.name}-ecs-codedeploy"

  # listener configuration (default)
  listener_default_configuration = var.load_balancer.alb_arn != null ? {
    "main" : {
      listener_arn       = var.load_balancer.default_listener_arn
      stickness_duration = 3000
    }
  } : {}

  listeners_arn_set = toset([for lstnr in local.listener_default_configuration : lstnr.listener_arn])

  # listener configuration (test)
  listener_test_configuration = var.load_balancer.alb_arn != null ? {
    "main" : {
      load_balancer_arn = var.load_balancer.alb_arn
      certificate_arn   = var.load_balancer.certificate_arn != "" ? var.load_balancer.certificate_arn : null
      port              = var.load_balancer.testing_listener_port > 0 ? var.load_balancer.testing_listener_port : 8443
    }
  } : {}

  # deployment configuration
  deployment_configuration = var.deployment.deployment_controller == "CODE_DEPLOY" ? {
    "main" : {
      name                             = local.name
      description                      = var.deployment.description
      deployment_controller            = var.deployment.deployment_controller
      deployment_config_name           = var.deployment.deployment_config_name
      auto_rollback_enabled            = var.deployment.auto_rollback_enabled
      auto_rollback_events             = var.deployment.auto_rollback_events
      action_on_timeout                = var.deployment.action_on_timeout
      wait_time_in_minutes             = var.deployment.wait_time_in_minutes
      termination_wait_time_in_minutes = var.deployment.termination_wait_time_in_minutes
    }
  } : {}

  # blue-tg identification
  blue_id = "blue"
  # green-tg identification
  green_id = "green"

  # canary tg groups 
  target_groups = {
    for tgs in [local.blue_id, local.green_id] :
    tgs => merge({
      name             = "${tgs}-${local.name}-${var.container_port}"
      backend_protocol = "HTTP"
      backend_port     = var.container_port
      target_type      = "ip"
      health_check     = lookup(var.load_balancer, "health_check", null)
    }, lookup(var.load_balancer, "target_group_additional_options", {}))
  }

  production_target_groups = {
    for tgs in [local.blue_id] :
    tgs => merge({
      name             = "${tgs}-${local.name}-${var.container_port}"
      backend_protocol = "HTTP"
      backend_port     = var.container_port
      target_type      = "ip"
      health_check     = lookup(var.load_balancer, "health_check", null)
    }, lookup(var.load_balancer, "target_group_additional_options", {}))
  }


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
}
