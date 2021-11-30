resource "aws_iam_role" "task_execution_role" {
  count = var.launch_type == "FARGATE" ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.task_execution_role_assume_role_policy.json
  name               = "ecs-task-execution-role-${var.name}"
}

data "aws_iam_policy_document" "task_execution_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "task_execution_role_policy" {
  count = var.launch_type == "FARGATE" ? 1 : 0

  name   = "${one(aws_iam_role.task_execution_role).name}-policy"
  role   = one(aws_iam_role.task_execution_role).name
  policy = data.aws_iam_policy_document.task_execution_role_policy_doc.json
}

data "aws_iam_policy_document" "task_execution_role_policy_doc" {

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecs:ListClusters",
      "ecs:ListTaskDefinitions",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:ListTasks",
      "ecs:DescribeTasks",
      "ecs:DescribeTaskDefinition",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecs:DescribeServices",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:UpdateService",
    ]

    resources = [
      aws_ecs_service.main.id,
      aws_ecs_task_definition.main.arn
    ]
  }

  statement {
    actions = [
      "iam:PassRole",
    ]

    resources = [
      aws_iam_role.task_role.arn
    ]
  }

  dynamic "statement" {
    for_each = var.iam_policy_statements_task_execution
    content {
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}


