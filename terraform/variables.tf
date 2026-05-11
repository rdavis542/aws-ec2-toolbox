variable "region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the toolbox"
  default     = "t3.small"
}

variable "volume_size" {
  type        = number
  description = "Root EBS volume size in GB"
  default     = 30
}

variable "vpc_name" {
  type        = string
  description = "Name tag of the existing VPC to deploy into"
  default     = "vpc-east-1"
}

variable "subnet_name" {
  type        = string
  description = "Name tag of the subnet to deploy into (public or private)"
  default     = "private-subnet-a"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Assign a public IP to the instance. Set to true for public subnets, false for private (SSM via NAT)."
  default     = false
}
