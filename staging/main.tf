locals {
  # You can declare local variables in the locals group, to avoid repetition
  common_tags = {
    env       = "staging"
    terraform = true
  }
  app1_tags = merge({
    project = "app1"
  }, local.common_tags)
}

## Get the default VPC and subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}
resource "aws_default_vpc" "default" {
}

# Deploy our app using the fargate module we wrote
module "app1" {
  source = "../modules/fargate"

  ecs_name         = "app1"
  docker_image     = "nginx"
  docker_image_tag = "1.21.6"
  desired_count    = 1
  vpc_id           = aws_default_vpc.default.id
  subnet_ids       = data.aws_subnets.default.ids

  tags = local.app1_tags
}

# Create a resource group so we can see all the resources fo the
# project in one place
resource "aws_resourcegroups_group" "app1" {
  name = "app1"
  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "project",
      "Values": ["app1"]
    }
  ]
}
JSON
  }
}
