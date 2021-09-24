data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS AWS CodeDeploy IAM Role
#
# https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/codedeploy_IAM_role.html

# https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "codedeploy" {
  for_each = local.deployment_configuration

  name               = "${local.iam_name}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  path               = "/"
  description        = each.value.description
  tags = merge(
    {
      "Name" = "${local.iam_name}-${each.key}"
    },
    var.tags,
  )
}

data "aws_iam_policy_document" "policy_deployer" {
  # If the tasks in your Amazon ECS service using the blue/green deployment type require the use of
  # the task execution role or a task role override, then you must add the iam:PassRole permission
  # for each task execution role or task role override to the AWS CodeDeploy IAM role as an inline policy.
  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:CreateTaskSet",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:DeleteTaskSet",
      "cloudwatch:DescribeAlarms",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = ["arn:aws:sns:*:*:CodeDeployTopic_*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:ModifyRule",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
    ]

    #TODO fix lambda ref
    resources = ["arn:aws:lambda:*:*:function:CodeDeployHook_*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectMetadata",
      "s3:GetObjectVersion",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/UseWithCodeDeploy"
      values   = ["true"]
    }

    resources = ["*"]
  }
}

# https://www.terraform.io/docs/providers/aws/r/iam_policy.html
resource "aws_iam_policy" "codedeploy" {
  for_each = local.deployment_configuration

  name        = "${local.iam_name}-${each.key}"
  policy      = data.aws_iam_policy_document.policy_deployer.json
  path        = "/"
  description = each.value.description

  tags = merge(
    {
      "Name" = "${local.iam_name}-${each.key}"
    },
    var.tags,
  )
}

# https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
resource "aws_iam_role_policy_attachment" "codedeploy" {
  for_each = local.deployment_configuration

  role       = aws_iam_role.codedeploy[each.key].name
  policy_arn = aws_iam_policy.codedeploy[each.key].arn
}


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}
