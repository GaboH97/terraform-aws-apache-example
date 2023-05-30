data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name               = aws_key_pair.deployer.key_name
  user_data              = templatefile("${abspath(path.module)}/userdata.yaml", {})
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]

  tags = {
    Name = var.server_name
  }
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "My Server SG"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "ingress_http" {
  security_group_id = aws_security_group.sg_my_server.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
}

resource "aws_security_group_rule" "ingress_ssh" {
  security_group_id = aws_security_group.sg_my_server.id

  type             = "ingress"
  from_port        = 22
  to_port          = 22
  protocol         = "tcp"
  cidr_blocks      = [var.my_ip]
  ipv6_cidr_blocks = []
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = aws_security_group.sg_my_server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}