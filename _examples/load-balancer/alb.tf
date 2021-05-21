#
# ALB
#
resource "aws_lb" "main" {
  name               = var.test_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = local.subnet_ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type  = "fixed-response"
    order = 999

    fixed_response {
      content_type = "text/plain"
      message_body = "503"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener_rule" "main_http" {

  listener_arn = aws_lb_listener.http.arn

  action {
    order            = 10
    type             = "forward"
    target_group_arn = module.ecs-service.blue_target_group
  }

  condition {
    host_header {
      values = ["*.*"] #todo
    }
  }

  lifecycle {
    ignore_changes = [
      action
    ]
  }
}

resource "aws_security_group" "lb_sg" {
  name   = "lb-${var.test_name}"
  vpc_id = local.vpc_id
}

resource "aws_security_group_rule" "app_lb_allow_outbound" {
  security_group_id = aws_security_group.lb_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_lb_allow_all_http" {
  security_group_id = aws_security_group.lb_sg.id
  type              = "ingress"
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "app_lb_allow_all_testing_port" {
  security_group_id = aws_security_group.lb_sg.id
  type              = "ingress"
  from_port         = local.testing_port
  to_port           = local.testing_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
