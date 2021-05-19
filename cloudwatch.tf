#
# CloudWatch
#

resource "aws_cloudwatch_log_group" "main" {
  name              = local.awslogs_group
  retention_in_days = var.cloudwatch.retention_in_days
  kms_key_id        = local.kms_key_id

  tags = var.tags
}
