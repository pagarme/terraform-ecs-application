#
# SG - ECS
#

resource "aws_security_group" "ecs_sg" {
  # checkov:skip=CKV2_AWS_5:Not required
  name        = "ecs-${var.name}-${var.environment}"
  description = "${var.name}-${var.environment} container security group"
  vpc_id      = var.networking.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "app_ecs_allow_outbound" {
  description       = "All outbound"
  security_group_id = aws_security_group.ecs_sg.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_ecs_allow_conn_from_container_to_alb" {
  # if we have an alb, then create security group rules for the container
  # ports
  count = var.load_balancer.alb_security_group_id != "" ? 1 : 0

  description       = "Allow container service ${local.name} connection to lb (for target groups)"
  security_group_id = aws_security_group.ecs_sg.id

  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = var.load_balancer.alb_security_group_id
}
