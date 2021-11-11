resource "aws_security_group" "main" {
  name        = "ecs-${data.aws_ecs_cluster.name}-service-${var.name}"
  description = "Security Group for the ECS Service ${var.name} of ${data.aws_ecs_cluster.name} cluster"
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
  for_each = var.source_security_group_ids

  description       = "Allow inbound from the load balancer"
  security_group_id = aws_security_group.main.id

  type                     = "ingress"
  from_port                = var.load_balancer_container_port
  to_port                  = var.load_balancer_container_port
  protocol                 = "tcp"
  source_security_group_id = each.key
}
