module "ecs_service" {
  source = "./modules/ecs/service"

  deployment_controller_type            = "CODE_DEPLOY"
  deployment_maximum_percent            = var.deployment_maximum_percent
  deployment_minimum_healthy_percent    = var.deployment_minimum_healthy_percent
  desired_count                         = var.desired_count
  ecs_cluster_arn                       = var.ecs_cluster_arn
  health_check_grace_period_seconds     = var.health_check_grace_period_seconds
  launch_type                           = var.launch_type
  load_balancer_container_name          = var.load_balancer_container_name
  load_balancer_container_port          = var.load_balancer_container_port
  load_balancer_target_group_arn        = var.load_balancer_target_group_arn
  name                                  = var.name
  network_assign_public_ip              = var.network_assign_public_ip
  network_subnets                       = var.network_subnets
  network_vpc_id                        = var.network_vpc_id
  platform_version                      = var.platform_version
  source_security_group_ids             = var.source_security_group_ids
  task_definition_container_definitions = var.task_definition_container_definitions
  task_definition_cpu                   = var.task_definition_cpu
  task_definition_memory                = var.task_definition_memory
}

module "code_deploy" {
  source = "./modules/code-deploy"

  auto_rollback_enabled                                        = var.code_deploy_auto_rollback_enabled
  auto_rollback_events                                         = var.code_deploy_auto_rollback_events
  deployment_config_name                                       = var.code_deploy_deployment_config_name
  deployment_ready_option_action_on_timeout                    = var.code_deploy_deployment_ready_option_action_on_timeout
  deployment_ready_option_wait_time_in_minutes                 = var.code_deploy_deployment_ready_option_wait_time_in_minutes
  deployment_termination_wait_time_in_minutes                  = var.code_deploy_deployment_termination_wait_time_in_minutes
  ecs_cluster_name                                             = var.ecs_cluster_name
  ecs_service_name                                             = module.ecs_service.name
  load_balancer_production_listener_arns                       = var.code_deploy_load_balancer_production_listener_arns
  load_balancer_target_groups_health_check_healthy_threshold   = var.code_deploy_load_balancer_target_groups_health_check_healthy_threshold
  load_balancer_target_groups_health_check_interval            = var.code_deploy_load_balancer_target_groups_health_check_interval
  load_balancer_target_groups_health_check_matcher             = var.code_deploy_load_balancer_target_groups_health_check_matcher
  load_balancer_target_groups_health_check_path                = var.code_deploy_load_balancer_target_groups_health_check_path
  load_balancer_target_groups_health_check_protocol            = var.code_deploy_load_balancer_target_groups_health_check_protocol
  load_balancer_target_groups_health_check_timeout             = var.code_deploy_load_balancer_target_groups_health_check_timeout
  load_balancer_target_groups_health_check_unhealthy_threshold = var.code_deploy_load_balancer_target_groups_health_check_unhealthy_threshold
  load_balancer_target_groups_port                             = var.code_deploy_load_balancer_target_groups_port
  load_balancer_target_groups_vpc_id                           = var.code_deploy_load_balancer_target_groups_vpc_id
  name                                                         = module.ecs_service.name
}
