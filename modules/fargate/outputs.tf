output "iam-task-role-arn" {
  value       = aws_iam_role.task-role.arn
  description = "ARN of the role assigned to the task"
}

output "lb-dns-name" {
  value       = aws_lb.lb.dns_name
  description = "Load balancer dns name"
}

output "lb-url" {
  value       = "http://${aws_lb.lb.dns_name}"
  description = "Load balancer url"
}

output "cluster_name" {
  value       = aws_ecs_cluster.cluster.name
  description = "Cluster name"
}

output "cluster_id" {
  value       = aws_ecs_cluster.cluster.id
  description = "Cluster id"
}

output "cluster_arn" {
  value       = aws_ecs_cluster.cluster.arn
  description = "Cluster ARN"
}

