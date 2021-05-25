### BASIC CONFIG

variable "environment" {
  description = "Environment tag, e.g prod."
  type        = string
}

variable "name" {
  description = "The service name."
  type        = string
}

variable "ecs_cluster" {
  description = "ECS cluster object for this task."
  type = object({
    arn  = string
    name = string
  })
}

variable "container_port" {
  description = "port used by conteiner service instantiated"
  type        = number
}

variable "container_definitions" {
  description = "Container definitions provided as valid JSON document. Default uses golang:alpine running a simple hello world."
  type        = string
}

variable "tasks_desired_count" {
  description = "The number of instances of a task definition."
  default     = 1
  type        = number
}

#### VPC

variable "networking" {
  description = "network configuration for the service"
  type = object({
    vpc_id           = string
    subnet_ids       = set(string)
    assign_public_ip = bool
  })
}

### CLOUDWATCH

variable "cloudwatch" {
  description = "cloudwatch configuration block"
  type = object({
    prefix_name       = string
    retention_in_days = number
  })

  default = {
    prefix_name       = "/ecs/fargate"
    retention_in_days = 7
  }
}

### IAM

variable "ecr_repo_arns" {
  description = "The ARNs of the ECR repos.  By default, allows all repositories."
  type        = set(string)
  default     = ["*"]
}

variable "ecs_instance_role" {
  description = "The name of the ECS instance role."
  default     = ""
  type        = string
}

### FARGATE

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

### DEPLOYMENT

variable "tasks_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks."
  default     = 100
  type        = number
}

variable "tasks_maximum_percent" {
  description = "Upper limit on the number of running tasks."
  default     = 200
  type        = number
}


### LOAD BALANCER

variable "load_balancer" {
  description = "load balancer information"



  type = object({
    alb_arn                 = string
    container_name          = string
    alb_security_group_id   = string
    production_listener_arn = string
    production_listener_rules = map(object({
      priority   = number
      actions    = set(any)
      conditions = set(any)
    }))
    testing_listener = object({
      port            = number
      protocol        = string
      certificate_arn = string
      ssl_policy      = string
    })
    health_check_grace_period_seconds = number
    target_group_additional_options   = map(any)
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
    # security group id of the load balancer
    alb_security_group_id = null
    # Grace period within which failed health checks will be ignored at container start. Only applies to services with an attached loadbalancer.
    health_check_grace_period_seconds = null
    # listener from production listener
    production_listener_arn = null
    # listener rules for production listener
    production_listener_rules = {
      "main" : {
        # priority of the rule
        priority = 10
        # actions of listener rule https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#action-blocks
        actions = []
        # conditions of listener rule https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#condition-blocks
        conditions = []
      }
    }
    # additional config from load balancer, this is a map for any configuration from terraform resource (see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#argument-reference)
    target_group_additional_options = {}
    # testing listener (deployment pass deploy)
    testing_listener = {
      # port used for testing listener
      port = -1
      # protocol used for testing listener
      protocol = "HTTP"
      # certificate ARN of the loadbalancer for testing listener
      certificate_arn = null
      # ssl policy for TLS in listener test
      ssl_policy = null
    }
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

variable "additional_security_group_ids" {
  description = "In addition to the security group created for the service, a list of security groups the ECS service should also be added to."
  default     = []
  type        = set(string)
}

####
# KMS configuration
####
variable "kms_key_id" {
  description = "KMS customer managed key (CMK) ARN for encrypting application logs."
  type        = string
  default     = ""
}

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

#### TAGS

variable "tags" {
  description = "tags for resources"
  type        = map(string)
  default = {
    module = "terraform-ecs-application"
  }
}
