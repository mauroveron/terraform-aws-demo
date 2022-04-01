//
// task role
//
resource "aws_iam_policy" "task-policy" {
  name        = "${var.ecs_name}-task-policy"
  path        = "/"
  description = "Policy used by the task to access AWS resources"
  tags        = local.common_tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
        ]
        Effect = "Allow"
        Resource = [
          "*",
        ]
      },
    ]
  })
}

resource "aws_iam_role" "task-role" {
  name = "${var.ecs_name}-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  tags = local.common_tags
}
resource "aws_iam_role_policy_attachment" "task-policy-attachment" {
  role       = aws_iam_role.task-role.name
  policy_arn = aws_iam_policy.task-policy.arn
}

