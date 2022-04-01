//
// IAM Execution role
//
resource "aws_iam_policy" "secrets" {
  name        = "${var.ecs_name}-task-policy-secrets"
  description = "Policy that allows access to the secrets we created"
  tags        = local.common_tags

  # FIXME: allow user to specity secrets
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AccessSecrets",
            "Effect": "Allow",
            "Action": [
              "secretsmanager:GetSecretValue"
            ],
            "Resource": "*"
          }
    ]
}
EOF
}

resource "aws_iam_role" "exec-role" {
  name = "${var.ecs_name}-ecsTaskExecutionRole"
  tags = local.common_tags

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

// Attach AWS Managed ECS execution role
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.exec-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment-secrets" {
  role       = aws_iam_role.exec-role.name
  policy_arn = aws_iam_policy.secrets.arn
}

