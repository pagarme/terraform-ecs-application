variable "region" {
  type    = string
  default = "us-east-1"
}

variable "azs" {
  type    = set(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "test_name" {
  type    = string
  default = "test-module"
}
