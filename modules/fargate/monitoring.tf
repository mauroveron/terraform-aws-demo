resource "aws_cloudwatch_metric_alarm" "http-req-count-alert" {
  alarm_name          = "${var.ecs_name}-http-req-count-alert"
  alarm_description   = "Monitor number of requests"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = "60"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  threshold           = 2000
  statistic           = "Sum"
  dimensions = {
    TargetGroup  = aws_lb_target_group.service-tg.arn_suffix
    LoadBalancer = aws_lb.lb.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "http-target-5xx-alert" {
  alarm_name          = "${var.ecs_name}-http-target-5xx-alert"
  alarm_description   = "Monitor HTTP 5XX errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = "60"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  threshold           = 100
  statistic           = "Sum"
  dimensions = {
    TargetGroup  = aws_lb_target_group.service-tg.arn_suffix
    LoadBalancer = aws_lb.lb.arn_suffix
  }
}

