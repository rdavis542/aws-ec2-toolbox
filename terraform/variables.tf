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
  description = "Name tag of the private subnet to deploy the instance into"
  default     = "private-subnet-a"
}
