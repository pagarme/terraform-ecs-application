data "aws_iam_policy_document" "instance_role_policy_doc" {
  count = var.ecs_use_fargate ? 0 : 1

  statement {
    actions = [
      "ecs:DeregisterContainerInstance",
      "ecs:RegisterContainerInstance",
      "ecs:Submit*",
    ]

    resources = [var.ecs_cluster_arn]
  }

  statement {
    actions = [
      "ecs:UpdateContainerInstancesState",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ecs:cluster"
      values   = [var.ecs_cluster_arn]
    }
  }

  statement {
    actions = [
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:StartTelemetrySession",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.main.arn}:*"]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = var.ecr_repo_arns
  }
}

resource "aws_iam_role_policy" "instance_role_policy" {
  count = var.ecs_use_fargate ? 0 : 1

  name   = "${var.name}-policy"
  role   = var.ecs_instance_role
  policy = one(data.aws_iam_policy_document.instance_role_policy_doc).json
}

data "aws_iam_policy_document" "task_execution_role_policy_doc" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.main.arn}:*"]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeRepositories",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:ListImages",
    ]

    resources = var.ecr_repo_arns
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

  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]

    resources = var.ssm_parameter_arns
  }
}



resource "aws_iam_role_policy" "task_execution_role_policy" {
  count = var.ecs_use_fargate ? 1 : 0

  name   = "${aws_iam_role.task_execution_role[count.index].name}-policy"
  role   = one(aws_iam_role.task_execution_role).name
  policy = data.aws_iam_policy_document.task_execution_role_policy_doc.json
}