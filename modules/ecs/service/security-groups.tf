resource "aws_security_group" "main" {
  name        = "ecs-${var.ecs_cluster_name}-service-${var.name}"
  description = "Security Group for the ECS Service ${var.name} of ${var.ecs_cluster_name} cluster"
  vpc_id      = var.network_vpc_id
}

resource "aws_security_group_rule" "egress" {
  description       = "Allow all"
  security_group_id = aws_security_group.main.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress" {
  description       = "Ingress rule"
  security_group_id = aws_security_group.main.id

  type                     = "ingress"
  from_port                = local.container_port
  to_port                  = local.container_port
  protocol                 = "tcp"
  source_security_group_id = var.source_security_group_id
}
