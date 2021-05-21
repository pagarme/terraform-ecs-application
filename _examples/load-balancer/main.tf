#
# ECS Cluster
#

resource "aws_ecs_cluster" "main" {
  name = var.test_name
}

#
# ECS Service
#
module "ecs-service" {
  source = "../../"

  name            = var.test_name
  ecs_cluster     = aws_ecs_cluster.main
  environment     = local.environment
  container_port  = local.container_port
  ecs_use_fargate = true

  load_balancer = {
    alb_arn                           = aws_lb.main.arn
    container_name                    = local.container_name
    alb_security_group_id             = aws_security_group.lb_sg.id
    production_listener_arn           = aws_lb_listener.http.arn
    health_check_grace_period_seconds = null
    target_group_additional_options   = {}

    testing_listener = {
      port            = local.testing_port
      protocol        = local.protocol
      ssl_policy      = null
      certificate_arn = null
    }

    # testing_listener = null

    health_check = {
      timeout             = 5
      interval            = 30
      path                = "/health"
      protocol            = local.protocol
      healthy_threshold   = 3
      unhealthy_threshold = 3
      matcher             = "200-399"
    }
  }

  deployment = {
    description                      = "deployer"
    deployment_controller            = "CODE_DEPLOY"
    deployment_config_name           = "CodeDeployDefault.ECSCanary10Percent5Minutes"
    auto_rollback_enabled            = true
    auto_rollback_events             = ["DEPLOYMENT_FAILURE"]
    action_on_timeout                = "STOP_DEPLOYMENT"
    wait_time_in_minutes             = 20
    termination_wait_time_in_minutes = 20
  }

  container_definitions = local.service_task_definition

  cloudwatch = {
    prefix_name       = local.log_prefix
    retention_in_days = 7
  }

  networking = {
    subnet_ids       = local.subnet_ids
    vpc_id           = local.vpc_id
    assign_public_ip = true
  }

  tags = local.tags
}
