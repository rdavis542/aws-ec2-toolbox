resource "aws_security_group" "toolbox" {
  name        = "${local.name}-sg"
  description = "Toolbox EC2 - SSM access only, no inbound"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    description = "Allow all outbound for AWS API calls and package installs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-sg"
  }
}
