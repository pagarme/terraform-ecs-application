variable "name" {
  description = "The service name."
  type        = string
}

variable "kms_key_id" {
  description = "KMS customer managed key (CMK) ARN for encrypting application logs."
  type        = string
}

variable "retention_in_days" {
  description = ""
  type        = number
}

variable "tags" {
  description = "tags for resources"
  type        = map(string)
  default = {
    module = "terraform-ecs-application"
  }
}
