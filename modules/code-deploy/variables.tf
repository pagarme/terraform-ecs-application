variable "auto_rollback_enabled" {
  type        = bool
  description = "Indicates whether a defined automatic rollback configuration is currently enabled for this Deployment Group. If you enable automatic rollback, you must specify at least one event type. Default: true"
  default     = true
}

variable "auto_rollback_events" {
  type        = set(string)
  description = "The event type or types that trigger a rollback. Supported types are DEPLOYMENT_FAILURE and DEPLOYMENT_STOP_ON_ALARM. Default: [DEPLOYMENT_FAILURE]"
  default     = ["DEPLOYMENT_FAILURE"]
}

variable "deployment_config_name" {
  type        = string
  description = "The name of the group's deployment config."
}

variable "deployment_ready_option_action_on_timeout" {
  type        = string
  description = "When to reroute traffic from an original environment to a replacement environment in a blue/green deployment. Supported types are CONTINUE_DEPLOYMENT and STOP_DEPLOYMENT."
}

variable "deployment_ready_option_wait_time_in_minutes" {
  type        = number
  description = "The number of minutes to wait before the status of a blue/green deployment changed to Stopped if rerouting is not started manually. Applies only to the STOP_DEPLOYMENT option for action_on_timeout. Default: 20"
  default     = 20
}

variable "deployment_termination_wait_time_in_minutes" {
  type        = number
  description = "The number of minutes to wait after a successful blue/green deployment before terminating instances from the original environment. Default: 20"
  default     = 20
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster."
}

variable "ecs_service_name" {
  type        = string
  description = "The name of the ECS service."
}

variable "load_balancer_production_listener_arn" {
  type        = string
  description = "ARN of the load balancer production listener."
}

variable "load_balancer_target_group_names" {
  type        = set(string)
  description = "Names of the blue and green target groups."
}

variable "name" {
  type        = string
  description = "The name of the application."
}
