variable "ssm_parameter_arns" {
  description = "set of ssm parameters arn to enable access to job"
  type        = set(string)
  default     = []
}
