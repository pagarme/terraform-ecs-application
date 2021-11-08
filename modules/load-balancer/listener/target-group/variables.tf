variable "port" {
  description = "port used by conteiner service instantiated"
  type        = number
}
variable "health_check" {
  description = "The target group health check."

  type = object({
    healthy_threshold   = number
    interval            = number
    matcher             = string
    path                = string
    protocol            = string
    timeout             = number
    unhealthy_threshold = number
  })

  default = {
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

variable "name" {
  description = "The target group name."
  type        = string
}

variable "vpc_id" {
  description = "The VPC id."
  type = string
}
