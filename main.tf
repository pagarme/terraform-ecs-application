module "ecs_service" {
  source = "./modules/ecs/service"

  deployment_controller_type            = "CODE_DEPLOY"
  deployment_maximum_percent            = var.deployment_maximum_percent
  deployment_minimum_healthy_percent    = var.deployment_minimum_healthy_percent
  desired_count                         = var.desired_count
  ecs_cluster_arn                       = var.ecs_cluster_arn
  ecs_cluster_name                      = var.ecs_cluster_name
  iam_policy_statements_task_execution  = var.iam_policy_statements_task_execution
  health_check_grace_period_seconds     = var.health_check_grace_period_seconds
  launch_type                           = var.launch_type
  load_balancer_container_name          = var.load_balancer_container_name
  load_balancer_target_group_arn        = var.load_balancer_target_group_arn
  name                                  = var.name
  network_assign_public_ip              = var.network_assign_public_ip
  network_subnets                       = var.network_subnets
  network_vpc_id                        = var.network_vpc_id
  platform_version                      = var.platform_version
  source_security_group_id              = var.source_security_group_id
  task_definition_container_definitions = var.task_definition_container_definitions
  task_definition_cpu                   = var.task_definition_cpu
  task_definition_memory                = var.task_definition_memory
}

module "code_deploy" {
  source = "./modules/code-deploy"

  auto_rollback_enabled                        = var.code_deploy_auto_rollback_enabled
  auto_rollback_events                         = var.code_deploy_auto_rollback_events
  deployment_config_name                       = var.code_deploy_deployment_config_name
  deployment_ready_option_action_on_timeout    = var.code_deploy_deployment_ready_option_action_on_timeout
  deployment_ready_option_wait_time_in_minutes = var.code_deploy_deployment_ready_option_wait_time_in_minutes
  deployment_termination_wait_time_in_minutes  = var.code_deploy_deployment_termination_wait_time_in_minutes
  ecs_cluster_name                             = var.ecs_cluster_name
  ecs_service_name                             = module.ecs_service.name
  load_balancer_production_listener_arn        = var.code_deploy_load_balancer_production_listener_arn
  load_balancer_target_group_names             = var.code_deploy_load_balancer_target_group_names
  name                                         = module.ecs_service.name
}
