data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  for_each          = var.azs
  vpc_id            = data.aws_vpc.default.id
  availability_zone = each.value
  default_for_az    = true
}


data "aws_caller_identity" "current" {}
