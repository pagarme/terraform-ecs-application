data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution_role" {
  count = var.launch_type == "FARGATE" ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  name               = "ecs-task-execution-role-${var.name}"
}

resource "aws_iam_role" "task_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  name               = "ecs-task-role-${var.name}"  
}
