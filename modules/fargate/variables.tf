variable "ecs_name" {
  type        = string
  description = "Name of the service"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Set the desired number of tasks"
}

variable "docker_image" {
  type        = string
  description = "Docker image to deploy"
}

variable "docker_image_tag" {
  type        = string
  default     = "latest"
  description = "Docker image tag to deploy"
}
variable "docker_repository_arn" {
  type        = string
  description = "ARN of the ECR repository"
  default     = ""
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "vpc_id" {
  type        = string
  description = "ID of the target VPC"
}

variable "subnet_ids" {
  type        = list(any)
  description = "Subnets ids to deploy the cluster to"
}
