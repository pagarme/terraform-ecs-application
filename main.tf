module "cloudwatch" {
  source = "./modules/cloudwatch"

  name = "${var.cloudwatch.prefix_name}/${var.name}"

  kms_key_id        = var.kms_key_id == "" ? null : var.kms_key_id
  retention_in_days = var.retention_in_days

  tags = var.tags
}

module "load_balancer_listener" {
  count = local.has_load_balancer ? 1 : 0
  source = "./modules/load-balancer/listener"

  name = local.name

  container_port = var.container_port
  load_balancer = {
    alb_arn          = var.load_balancer.alb_arn
    testing_listener = var.load_balancer.testing_listener
    target_group_additional_options = var.load_balancer.target_group_additional_options
    health_check = var.load_balancer.health_check
  }
  vpc_id = var.networking.vpc_id

  tags = var.tags
}

module "load_balancer_listener_rule" {
  count = local.has_load_balancer ? 1 : 0
  source = "./modules/load-balancer/listener/rule"

  listener_arn = var.load_balancer.production_listener_arn
  listener_rules = var.load_balancer.production_listener_rules

  tags = var.tags
}

module "code_deploy" {
  source = "./modules/code-deploy"

  count = var.deployment.deployment_controller == "CODE_DEPLOY" && local.has_load_balancer ? 1 : 0

  name = var.name

  deployment                  = var.deployment
  ecs_cluster_name            = var.ecs_cluster.name
  listener_test_configuration = module.load_balancer_listener.listener_test_configuration
  production_listener_arn     = var.load_balancer.production_listener_arn
  target_groups               = module.load_balancer_listener.target_groups
  testing_route               = module.load_balancer_listener.testing_route

  tags = var.tags
}

module "ecs_service" {
  source = "./module/ecs/service"

  name = local.name

  additional_security_group_ids = var.additional_security_group_ids
  alb_security_group_ids = local.has_load_balancer ? toset(compact([var.load_balancer.alb_security_group_id])) : []
  container_definitions = var.container_definitions
  container_port = var.container_port
  deployment_controller = var.deployment.deployment_controller
  ecr_repo_arns = var.ecr_repo_arns
  ecs_cluster_arn = var.ecs_cluster.arn
  ecs_instance_role = var.ecs_instance_role
  ecs_use_fargate = var.ecs_use_fargate
  fargate_options = var.fargate_options
  load_balancer = {
    alb_arn = var.load_balancer.alb_arn
    container_name = var.load_balancer.container_name
    target_group_additional_options = var.load_balancer.target_group_additional_options
    health_check_grace_period_seconds = var.load_balancer.health_check_grace_period_seconds
    health_check = var.load_balancer.health_check
  }
  networking = var.networking
  service_registries = var.service_registries
  ssm_parameter_arns = var.ssm_parameter_arns
  tasks_desired_count = var.tasks_desired_count
  tasks_maximum_percent = var.tasks_maximum_percent
  tasks_minimum_healthy_percent = var.tasks_minimum_healthy_percent

  tags = var.tags
}
