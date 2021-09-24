locals {
  # name of the service
  name = "${var.name}-${var.environment}"

  #check if an ALB will be created
  has_load_balancer = var.load_balancer.alb_arn == null ? false : true
}
