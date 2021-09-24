variable "listener_arn" {
  type = string
  description = "production listener arn"
}

variable "listener_rules" {
  description = "Production listener rules"
  type = map(object({
    priority   = number
    actions    = set(any)
    conditions = set(any)
  }))

  default = {
    "main" : {
      # priority of the rule
      priority = 10
      # actions of listener rule https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#action-blocks
      actions = []
      # conditions of listener rule https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#condition-blocks
      conditions = []
    }
  }
}

variable "tags" {
  description = "tags for resources"
  type        = map(string)
  default = {
    module = "terraform-ecs-application"
  }
}
