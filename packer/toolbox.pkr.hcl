packer {
  required_version = ">= 1.10.0"
  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "vpc_name" {
  type        = string
  description = "Name tag of the VPC to run the build instance in"
  default     = "vpc-east-1"
}

variable "build_subnet_name" {
  type        = string
  description = "Name tag of the subnet for the Packer build instance. Must have internet access (public subnet or private with NAT)."
  default     = "public-subnet-a"
}

locals {
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
  ami_name  = "ec2-toolbox-${local.timestamp}"
}

data "amazon-ami" "al2023" {
  region = var.region
  owners = ["amazon"]

  filters = {
    name                = "al2023-ami-*-kernel-*-x86_64"
    virtualization-type = "hvm"
    state               = "available"
  }

  most_recent = true
}

source "amazon-ebs" "toolbox" {
  region        = var.region
  instance_type = var.instance_type
  source_ami    = data.amazon-ami.al2023.id

  ami_name        = local.ami_name
  ami_description = "AWS EC2 Toolbox — AL2023, AWS CLI v2, network diagnostics, troubleshooting aliases"

  vpc_filter {
    filters = {
      "tag:Name" = var.vpc_name
    }
  }

  subnet_filter {
    filters = {
      "tag:Name" = var.build_subnet_name
    }
    most_free = true
  }

  associate_public_ip_address = true

  ssh_username = "ec2-user"

  temporary_iam_instance_profile_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  tags = {
    Name      = local.ami_name
    Project   = "aws-ec2-toolbox"
    ManagedBy = "Packer"
    BaseAMI   = data.amazon-ami.al2023.id
    BuildDate = local.timestamp
    Owner     = "ryan_davis542@outlook.com"
  }

  snapshot_tags = {
    Name    = local.ami_name
    Project = "aws-ec2-toolbox"
  }
}

build {
  sources = ["source.amazon-ebs.toolbox"]

  provisioner "shell" {
    script          = "scripts/setup.sh"
    execute_command = "sudo bash '{{.Path}}'"
  }
}
