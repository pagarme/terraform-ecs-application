locals {
  # name of the service
  name = "${var.name}-${var.environment}"
  # log-group
  awslogs_group = "${var.cloudwatch.prefix_name}/${var.name}"
  # kms configuration
  kms_key_id = var.kms_key_id == "" ? null : var.kms_key_id

  #check if an ALB will be created
  has_load_balancer = var.load_balancer.alb_arn == null ? false: true

  # iam
  iam_name = "${var.name}-ecs-codedeploy"

  # security group of alb if have alb
  alb_security_group_ids = var.load_balancer.alb_arn != null ? toset(compact([var.load_balancer.alb_security_group_id])) : []

  # listener configuration (default)
  production_listener = var.load_balancer.alb_arn != null ? var.load_balancer.production_listener_arn : null

  # listener rules configuration (default)
  production_listener_rules = var.load_balancer.alb_arn != null ? var.load_balancer.production_listener_rules : {}

  # listener configuration (test)
  listener_test_configuration = (var.load_balancer.alb_arn != null && var.load_balancer.testing_listener != null) ? {
    "main" : {
      load_balancer_arn = var.load_balancer.alb_arn
      certificate_arn   = var.load_balancer.testing_listener.certificate_arn != "" ? var.load_balancer.testing_listener.certificate_arn : null
      ssl_policy        = var.load_balancer.testing_listener.ssl_policy != "" ? var.load_balancer.testing_listener.ssl_policy : null
      protocol          = var.load_balancer.testing_listener.protocol != "" ? var.load_balancer.testing_listener.protocol : "HTTP"
      port              = var.load_balancer.testing_listener.port > 0 ? var.load_balancer.testing_listener.port : 8443
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
