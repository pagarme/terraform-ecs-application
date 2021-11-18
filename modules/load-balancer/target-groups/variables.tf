variable "health_check_healthy_threshold" {
  type        = number
  description = "Number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3."
  default     = 3
}

variable "health_check_interval" {
  type        = number
  description = "Approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. Default: 30"
  default     = 30
}

variable "health_check_matcher" {
  type        = string
  description = "Response codes to use when checking for a healthy responses from a target. Default: 200-299"
  default     = "200-299"
}

variable "health_check_path" {
  type        = string
  description = "Destination for the health check request."
  default     = "/"
}

variable "health_check_protocol" {
  type        = string
  description = "Protocol to use to connect with the target. Default: HTTP"
  default     = "HTTP"
}

variable "health_check_timeout" {
  type        = number
  description = "Amount of time, in seconds, during which no response means a failed health check. Default: 10"
  default     = 10
}

variable "health_check_unhealthy_threshold" {
  type        = number
  description = "Number of consecutive health check failures required before considering the target unhealthy. Default: 3"
  default     = 3
}

variable "name" {
  type        = string
  description = "The name of the target groups."
}

variable "port" {
  description = "Port on which the blue and green targets receive traffic."
  type        = number
}

variable "vpc_id" {
  description = "The VPC id."
  type        = string
}

