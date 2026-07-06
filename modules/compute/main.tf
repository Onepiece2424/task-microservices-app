data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "bastion_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true # パブリックIP付与
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  key_name                    = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "public-ec2"
  }
}
resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = var.private_subnet_ids[0]
  associate_public_ip_address = false # パブリックIPを付与しない
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  key_name                    = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "private-ec2"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file(pathexpand("~/.ssh/ec2-keypair-new.pub"))
}

resource "aws_security_group" "public_sg" {
  name        = "public_sg_allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "public-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_public_sg" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "${var.my_ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_public_sg" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "private_sg" {
  name        = "private_sg_allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "private-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_private_sg" {
  security_group_id            = aws_security_group.private_sg.id
  referenced_security_group_id = aws_security_group.public_sg.id

  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_private_sg" {
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
