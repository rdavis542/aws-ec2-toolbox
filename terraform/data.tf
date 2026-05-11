data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_name]
  }
}

data "aws_ami" "toolbox" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Project"
    values = ["aws-ec2-toolbox"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
