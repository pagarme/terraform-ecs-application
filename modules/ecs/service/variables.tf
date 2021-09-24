variable "additional_security_group_ids" {
  description = "In addition to the security group created for the service, a list of security groups the ECS service should also be added to."
  default     = []
  type        = set(string)
}

variable "alb_security_group_ids" {
  description = "alb security group ids"
  type        = list(string)
}

variable "container_definitions" {
  description = "Container definitions provided as valid JSON document. Default uses golang:alpine running a simple hello world."
  type        = string
}

variable "container_port" {
  description = "port used by conteiner service instantiated"
  type        = number
}

variable "deployment_controller" {
  description = "deployment controller (ECS | CODE_DEPLOY | EXTERNAL)"
  type        = string
  default     = "ECS"
}

variable "ecr_repo_arns" {
  description = "The ARNs of the ECR repos"
  type        = set(string)
  default     = []
}

variable "ecs_cluster_arn" {
  description = "ECS cluster arn."
  type        = string
}

variable "ecs_instance_role" {
  description = "The name of the ECS instance role."
  default     = ""
  type        = string
}

variable "ecs_use_fargate" {
  description = "Whether to use Fargate for the task definition."
  default     = false
  type        = bool
}

variable "fargate_options" {
  description = "Fargate options for ECS fargate task"
  type = object({
    platform_version = string
    task_cpu         = number
    task_memory      = number
  })

  default = {
    platform_version = "1.4.0"
    task_cpu         = 256
    task_memory      = 512
  }
}

variable "load_balancer" {
  description = "load balancer information"

  type = object({
    alb_arn                           = string
    container_name                    = string
    target_group_additional_options   = map(any)
    health_check_grace_period_seconds = number
    health_check = object({
      healthy_threshold   = number
      interval            = number
      matcher             = string
      path                = string
      protocol            = string
      timeout             = number
      unhealthy_threshold = number
    })
  })

  default = {
    alb_arn = null
    # name of the conteiner reference to join in load_balancer definition in service configuration
    container_name = null
    # additional config from load balancer, this is a map for any configuration from terraform resource (see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#argument-reference)
    target_group_additional_options = {}
    # Grace period within which failed health checks will be ignored at container start. Only applies to services with an attached loadbalancer.
    health_check_grace_period_seconds = null
    # health check configuration to enable inner all target groups (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#health_check)
    health_check = {
      # healthy_threshold - (Optional) Number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3.
      healthy_threshold = 3
      # interval - (Optional) Approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. For lambda target groups, it needs to be greater as the timeout of the underlying lambda. Default 30 seconds.
      interval = 30
      # matcher (May be required) Response codes to use when checking for a healthy responses from a target. You can specify multiple values (for example, "200,202" for HTTP(s) or "0,12" for GRPC) or a range of values (for example, "200-299" or "0-99"). Required for HTTP/HTTPS/GRPC ALB. Only applies to Application Load Balancers (i.e., HTTP/HTTPS/GRPC) not Network Load Balancers (i.e., TCP).
      matcher = "200-299"
      # path - (May be required) Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS.
      path = "/"
      # protocol - (Optional) Protocol to use to connect with the target. Defaults to HTTP. Not applicable when target_type is lambda.
      protocol = "HTTP"
      # timeout - (Optional) Amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 120 seconds, and the default is 5 seconds for the instance target type and 30 seconds for the lambda target type. For Network Load Balancers, you cannot set a custom value, and the default is 10 seconds for TCP and HTTPS health checks and 6 seconds for HTTP health checks.
      timeout = 10
      # unhealthy_threshold - (Optional) Number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold. Defaults to 3.
      unhealthy_threshold = 3
    }
  }
}

variable "name" {
  type        = string
  description = "service name"
}

variable "networking" {
  description = "network configuration for the service"
  type = object({
    vpc_id           = string
    subnet_ids       = set(string)
    assign_public_ip = bool
  })
}

variable "service_registries" {
  description = "List of service registry objects as per <https://www.terraform.io/docs/providers/aws/r/ecs_service.html#service_registries-1>. List can only have a single object until <https://github.com/terraform-providers/terraform-provider-aws/issues/9573> is resolved."
  type = set(object({
    registry_arn   = string
    container_name = string
    container_port = number
    port           = number
  }))
  default = []
}

variable "ssm_parameter_arns" {
  description = "set of ssm parameters arn to enable access to job"
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "tags for resources"
  type        = map(string)
  default = {
    module = "terraform-ecs-application"
  }
}

variable "tasks_desired_count" {
  description = "The number of instances of a task definition."
  default     = 1
  type        = number
}

variable "tasks_maximum_percent" {
  description = "Upper limit on the number of running tasks."
  default     = 200
  type        = number
}

variable "tasks_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks."
  default     = 100
  type        = number
}
