##### ECS information

output "ecs_security_group_id" {
  description = "Security Group ID assigned to the ECS tasks."
  value       = aws_security_group.ecs_sg.id
}

output "task_execution_role_arn" {
  description = "The ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  value       = one(aws_iam_role.task_execution_role.*.arn)
}

output "task_execution_role_name" {
  description = "The name of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  value       = one(aws_iam_role.task_execution_role.*.name)
}

output "task_role_arn" {
  description = "The ARN of the IAM role assumed by Amazon ECS container tasks."
  value       = aws_iam_role.task_role.arn
}

output "task_role_name" {
  description = "The name of the IAM role assumed by Amazon ECS container tasks."
  value       = aws_iam_role.task_role.name
}

output "task_role" {
  description = "The IAM role object assumed by Amazon ECS container tasks."
  value       = aws_iam_role.task_role
}

output "task_execution_role" {
  description = "The role object of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  value       = aws_iam_role.task_execution_role
}

output "service_arn" {
  description = "service identification ARN"
  value       = aws_ecs_service.main.id
}

output "task_definition_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = aws_ecs_task_definition.main.arn
}

output "task_definition_family" {
  description = "The family of the Task Definition."
  value       = aws_ecs_task_definition.main.family
}

output "awslogs_group" {
  description = "Name of the CloudWatch Logs log group containers should use."
  value       = local.awslogs_group
}

output "awslogs_group_arn" {
  description = "ARN of the CloudWatch Logs log group containers should use."
  value       = aws_cloudwatch_log_group.main.arn
}


##### Target groups information

output "blue_target_group" {
  value       = aws_lb_target_group.this["blue"] != null ? aws_lb_target_group.this["blue"].arn : null
  description = "(Application Load Balancer) production target groups"
}

output "green_target_group" {
  value       = aws_lb_target_group.this["green"] != null ? aws_lb_target_group.this["green"].arn : null
  description = "(Application Load Balancer) production target groups"
}



#### For codedeploy features
output "codedeploy_app_id" {
  value       = one([for it in aws_codedeploy_app.this : it.id])
  description = "(CodeDeploy) Amazon's assigned ID for the application."
}

output "codedeploy_app_name" {
  value       = one([for it in aws_codedeploy_app.this : it.name])
  description = "(CodeDeploy) The application's name."
}

output "codedeploy_deployment_group_id" {
  value       = one([for it in aws_codedeploy_deployment_group.this : it.id])
  description = "(CodeDeploy) Application name and deployment group name."
}

output "codedeploy_iam_role_arn" {
  value       = one([for it in aws_iam_role.codedeploy : it.arn])
  description = "(CodeDeploy) The Amazon Resource Name (ARN) specifying the IAM Role."
}

output "codedeploy_iam_role_name" {
  value       = one([for it in aws_iam_role.codedeploy : it.name])
  description = "(CodeDeploy) The name of the IAM Role."
}

output "codedeploy_iam_policy_id" {
  value       = one([for it in aws_iam_policy.codedeploy : it.id])
  description = "(CodeDeploy) The IAM Policy's ID."
}

output "codedeploy_iam_policy_arn" {
  value       = one([for it in aws_iam_policy.codedeploy : it.arn])
  description = "(CodeDeploy) The ARN assigned by AWS to this IAM Policy."
}

output "codedeploy_iam_policy_name" {
  value       = one([for it in aws_iam_policy.codedeploy : it.name])
  description = "(CodeDeploy) The name of the IAM Policy."
}
