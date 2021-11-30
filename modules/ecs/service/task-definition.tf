resource "aws_ecs_task_definition" "main" {
  family        = var.name
  network_mode  = "awsvpc"
  task_role_arn = aws_iam_role.task_role.arn

  requires_compatibilities = [var.launch_type]
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory
  execution_role_arn       = join("", aws_iam_role.task_execution_role.*.arn)

  container_definitions = var.task_definition_container_definitions

  lifecycle {
    ignore_changes = [container_definitions]
  }
}
