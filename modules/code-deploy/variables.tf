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

variable "load_balancer_production_listener_arns" {
  type        = set(string)
  description = "List of Amazon Resource Names (ARNs) of the load balancer listeners."
}

variable "load_balancer_target_groups_health_check_healthy_threshold" {
  type        = number
  description = "Number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3."
  default     = 3
}

variable "load_balancer_target_groups_health_check_interval" {
  type        = number
  description = "Approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. Default: 30"
  default     = 30
}

variable "load_balancer_target_groups_health_check_matcher" {
  type        = string
  description = "Response codes to use when checking for a healthy responses from a target. Default: 200-299"
  default     = "200-299"
}

variable "load_balancer_target_groups_health_check_path" {
  type        = string
  description = "Destination for the health check request."
  default     = "/"
}

variable "load_balancer_target_groups_health_check_protocol" {
  type        = string
  description = "Protocol to use to connect with the target. Default: HTTP"
  default     = "HTTP"
}

variable "load_balancer_target_groups_health_check_timeout" {
  type        = number
  description = "Amount of time, in seconds, during which no response means a failed health check. Default: 10"
  default     = 10
}

variable "load_balancer_target_groups_health_check_unhealthy_threshold" {
  type        = number
  description = "Number of consecutive health check failures required before considering the target unhealthy. Default: 3"
  default     = 3
}

variable "load_balancer_target_groups_port" {
  description = "Port on which the blue and green targets receive traffic."
  type        = number
}

variable "load_balancer_target_groups_vpc_id" {
  description = "The VPC id."
  type        = string
}

variable "name" {
  type        = string
  description = "The name of the application."
}
