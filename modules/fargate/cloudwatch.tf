
resource "aws_cloudwatch_log_group" "cloudwatch-logs" {
  name = "/ecs/${var.ecs_name}"

  tags              = local.common_tags
  retention_in_days = 30
}
