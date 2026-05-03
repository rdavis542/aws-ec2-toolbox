output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.toolbox.id
}

output "instance_arn" {
  description = "EC2 instance ARN"
  value       = aws_instance.toolbox.arn
}

output "private_ip" {
  description = "Private IP address of the toolbox instance"
  value       = aws_instance.toolbox.private_ip
}

output "availability_zone" {
  description = "Availability zone the instance was launched in"
  value       = aws_instance.toolbox.availability_zone
}

output "security_group_id" {
  description = "Security group ID attached to the instance"
  value       = aws_security_group.toolbox.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the instance"
  value       = aws_iam_role.toolbox.arn
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.toolbox.name
}

output "ssm_connect_command" {
  description = "AWS CLI command to open an SSM session to this instance"
  value       = "aws ssm start-session --target ${aws_instance.toolbox.id} --region ${local.region}"
}
