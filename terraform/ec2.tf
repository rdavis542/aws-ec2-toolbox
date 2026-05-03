resource "aws_instance" "toolbox" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.toolbox.name
  subnet_id              = data.aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.toolbox.id]
  user_data              = local.user_data

  monitoring = true

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = local.name
  }
}
