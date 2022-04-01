resource "aws_lb_target_group" "service-tg" {
  name        = "${var.ecs_name}-service-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    enabled             = true
    interval            = 15
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
    timeout             = 10
    path                = "/"
  }
  vpc_id = var.vpc_id

  tags = local.common_tags
}

resource "aws_security_group" "lb" {
  name        = "${var.ecs_name}-lb-sg"
  description = "${var.ecs_name} load balancer traffic rules"
  tags        = local.common_tags
}

resource "aws_security_group_rule" "lb-in" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  protocol          = "-1"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb-out" {
  security_group_id = aws_security_group.lb.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb" "lb" {
  name               = var.ecs_name
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.lb.id
  ]
  subnets = var.subnet_ids
  tags    = local.common_tags
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service-tg.arn
  }
}
