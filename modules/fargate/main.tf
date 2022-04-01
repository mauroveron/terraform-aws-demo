locals {
  common_tags = var.tags
}

resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_name
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = "/ecs/${var.ecs_name}"
      }
    }
  }
  tags = local.common_tags
}

resource "aws_ecs_cluster_capacity_providers" "capacity" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "task-definition" {
  tags                     = local.common_tags
  family                   = var.ecs_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.exec-role.arn
  task_role_arn            = aws_iam_role.task-role.arn
  depends_on = [
    aws_cloudwatch_log_group.cloudwatch-logs
  ]
  container_definitions = jsonencode([{
    name      = var.ecs_name
    image     = "${var.docker_image}:${var.docker_image_tag}"
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.ecs_name}"
        awslogs-region        = "${data.aws_region.current_region.name}"
        awslogs-stream-prefix = var.ecs_name
      }
    }
    environment = []
  }])
}

resource "aws_security_group" "service-sg" {
  name        = "${var.ecs_name}-service-sg"
  description = "${var.ecs_name}-service traffic rules"
  vpc_id      = var.vpc_id
  tags        = local.common_tags
}

resource "aws_security_group_rule" "service-direct-in" {
  security_group_id = aws_security_group.service-sg.id
  type              = "ingress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "service-direct-out" {
  security_group_id = aws_security_group.service-sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "service-lb-in" {
  security_group_id        = aws_security_group.service-sg.id
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "service-lb-out" {
  security_group_id        = aws_security_group.service-sg.id
  type                     = "egress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_ecs_service" "service" {
  name                              = var.ecs_name
  cluster                           = aws_ecs_cluster.cluster.id
  task_definition                   = aws_ecs_task_definition.task-definition.arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  enable_execute_command            = false
  enable_ecs_managed_tags           = true
  tags                              = local.common_tags
  health_check_grace_period_seconds = 300
  propagate_tags                    = "SERVICE"

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service-tg.arn
    container_name   = var.ecs_name
    container_port   = 80
  }

  network_configuration {
    subnets = var.subnet_ids
    security_groups = [
      aws_security_group.service-sg.id,
      aws_security_group.lb.id
    ]

    # needs to be public IP, otherwise the container won't start
    assign_public_ip = true
  }
}

