# Create a task definition with a golang image so the ecs service can be
# tested. We expect deployments will manage the future container definitions.
resource "aws_ecs_task_definition" "main" {
  family        = var.name
  network_mode  = "awsvpc"
  task_role_arn = aws_iam_role.task_role.arn

  # Fargate requirements
  requires_compatibilities = compact([var.ecs_use_fargate ? "FARGATE" : ""])
  cpu                      = var.ecs_use_fargate ? var.fargate_options.task_cpu : ""
  memory                   = var.ecs_use_fargate ? var.fargate_options.task_memory : ""
  execution_role_arn       = join("", aws_iam_role.task_execution_role.*.arn)

  container_definitions = var.container_definitions

  lifecycle {
    ignore_changes = [
      requires_compatibilities,
      cpu,
      memory,
      execution_role_arn,
      container_definitions
    ]
  }

  tags = var.tags
}

# Create a data source to pull the latest active revision from
data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.main.family
  depends_on      = [aws_ecs_task_definition.main] # ensures at least one task def exists
}