variable "launch_type" {
  description = "Use FARGATE or EC2. Default: FARGATE"
  default     = "FARGATE"
  type        = string
}

variable "platform_version" {
  default = "1.4.0"
  type    = string
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "source_security_group_ids" {
  type    = list(string)
  default = []
}

variable "name" {
  type        = string
  description = "service name"
}

variable "container_definitions" {
  description = "Container definitions provided as valid JSON document. Default uses golang:alpine running a simple hello world."
  type        = string
}

variable "deployment_controller_type" {
  description = "deployment controller type (ECS | CODE_DEPLOY | EXTERNAL). Default: ECS"
  type        = string
  default     = "ECS"
}
variable "ecs_cluster_arn" {
  description = "ECS cluster arn."
  type        = string
}

variable "health_check_grace_period_seconds" {
  type = number
}

variable "load_balancer" {
  description = "load balancer information"

  type = object({
    container_name   = string
    container_port   = number
    target_group_arn = string
  })
}

variable "network_configuration" {
  description = "network configuration for the service"
  type = object({
    vpc_id           = string
    subnets          = set(string)
    assign_public_ip = bool
  })
}

variable "tags" {
  description = "tags for resources"
  type        = map(string)
  default = {
    module = "terraform-ecs-application"
  }
}

variable "desired_count" {
  description = "The number of instances of a task definition."
  default     = 1
  type        = number
}

variable "deployment_maximum_percent" {
  description = "Upper limit on the number of running tasks."
  default     = 200
  type        = number
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks."
  default     = 100
  type        = number
}
