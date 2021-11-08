variable "deployment" {
  description = "Deployment configuration, deployment resources will be created if deployment_controller is CODE_DEPLOY"
  type = object({
    description                      = string
    deployment_controller            = string
    deployment_config_name           = string
    auto_rollback_enabled            = bool
    auto_rollback_events             = set(string)
    action_on_timeout                = string
    wait_time_in_minutes             = number
    termination_wait_time_in_minutes = number
  })

  default = {
    # enabled - description for codedeploy policies/roles
    description = "deployer"
    # deployment controller type of the service options (ECS | CODE_DEPLOY | EXTERNAL)
    deployment_controller = "ECS"
    # deployment config name for rolling deploy rules (https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html)
    deployment_config_name = null
    # rollback will be triggered on error without interaction?  (true/false)
    auto_rollback_enabled = true
    # events will trigger rollback in case of error
    auto_rollback_events = ["DEPLOYMENT_FAILURE"]
    # action to perform on timeout
    action_on_timeout = "STOP_DEPLOYMENT"
    # wait time in minutes in verification window
    wait_time_in_minutes = 20
    # wait time in minutes in wait termination window
    termination_wait_time_in_minutes = 20
  }
}

variable "ecs_cluster_arn" {
  description = "ECS cluster arn."
  type        = string
}

variable "name" {
  description = "The service name."
  type        = string
}

variable "production_listener_arn" {
  type = string
  description = "production listener arn"
}

variable "tags" {
  description = "tags for resources"
  type        = map(string)
  default = {
    module = "terraform-ecs-application"
  }
}

variable "target_groups" {
  type        = object({})
  description = "(optional) describe your variable"
}
