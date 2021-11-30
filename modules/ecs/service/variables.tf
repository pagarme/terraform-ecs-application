variable "deployment_controller_type" {
  type        = string
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS, EXTERNAL. Default: ECS"
  default     = "ECS"
}

variable "deployment_maximum_percent" {
  type        = number
  description = "Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. Default: 200"
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment. Default: 100"
  default     = 100
}

variable "desired_count" {
  type        = number
  description = "Number of instances of the task definition to place and keep running. Default: 1"
  default     = 1
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster"
}

variable "health_check_grace_period_seconds" {
  type        = number
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Default: 60"
  default     = 60
}

variable "iam_policy_statements_task_execution" {
  type = set(object({
    actions   = set(string)
    resources = set(string)
  }))
  description = "Additional policy statements for the task execution role policy."
  default     = []
}

variable "launch_type" {
  type        = string
  description = "Use FARGATE or EC2. Default: FARGATE"
  default     = "FARGATE"
}

variable "load_balancer_container_name" {
  type        = string
  description = "Name of the container to associate with the load balancer (as it appears in a container definition)."
}

variable "load_balancer_target_group_arn" {
  type        = string
  description = "ARN of the Load Balancer target group to associate with the service."
}

variable "name" {
  type        = string
  description = "Name of the service"
}

variable "network_assign_public_ip" {
  type        = bool
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false."
  default     = false
}

variable "network_subnets" {
  type        = set(string)
  description = "Subnets associated with the task or service."
}

variable "network_vpc_id" {
  type        = string
  description = "The VPC id."
}

variable "platform_version" {
  type        = string
  description = "Platform version on which to run your service. Only applicable for launch_type set to FARGATE. Default: 1.4.0"
  default     = "1.4.0"
}

variable "source_security_group_id" {
  type        = string
  description = "Security group id to allow access from"
}

variable "task_definition_container_definitions" {
  type        = string
  description = "A list of valid container definitions provided as a single valid JSON document."
}

variable "task_definition_cpu" {
  type        = number
  description = "Number of cpu units used by the task. If the launch_type is FARGATE this field is required."
}

variable "task_definition_memory" {
  type        = number
  description = "Amount (in MiB) of memory used by the task. If the launch_type is FARGATE this field is required."
}
