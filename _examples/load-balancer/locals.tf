locals {
  environment    = "test"
  protocol       = "HTTP"
  container_port = 3000
  http_port      = 80
  testing_port   = 8080

  log_prefix     = "/ecs/${local.environment}"
  log_group      = "/ecs/${local.environment}/${var.test_name}"
  container_url  = "quay.io/claytonsilva/nodejs-application-deployment-demo:release-1.2.1"
  container_name = "${var.test_name}-${local.environment}"
  vpc_id         = data.aws_vpc.default.id
  subnet_ids     = [for subnet in data.aws_subnet.default : subnet.id]
  service_task_definition = jsonencode([{
    "essential" : true,
    "image" : local.container_url,
    "name" : local.container_name,
    "memoryReservation" : 100,
    "logConfiguration" : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : local.log_group,
        "awslogs-region" : var.region,
        "awslogs-stream-prefix" : local.log_prefix
      }
    },
    "portMappings" : [
      {
        "containerPort" : local.container_port,
        "hostPort" : local.container_port,
        "protocol" : "tcp"
      }
    ]
  }])

  tags = {
    Environment = local.environment
    Automation  = "terraform"
  }
}
