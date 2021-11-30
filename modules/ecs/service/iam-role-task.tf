resource "aws_iam_role" "task_role" {
  assume_role_policy = data.aws_iam_policy_document.task_role_assume_role_policy.json
  name               = "ecs-task-role-${var.name}"
}

data "aws_iam_policy_document" "task_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
