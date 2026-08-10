locals {
  description = "creating local variable"
  name        = "My"
}

#----------------------------------------------------
# VPC
#----------------------------------------------------

resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr

  tags = {
    Name = "${local.name}-VPC"
  }
}

#----------------------------------------------------
# Internet Gateway
#----------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "${local.name}-IGW"
  }
}

#----------------------------------------------------
# Public Subnet 1
# AZ: ap-south-1a
#----------------------------------------------------

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet1_cidr
  availability_zone       = var.az_1a
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-Public-Subnet-1"
  }
}

#----------------------------------------------------
# Public Subnet 2
# AZ: ap-south-1b
#----------------------------------------------------

resource "aws_subnet" "publicsubnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet2_cidr
  availability_zone       = var.az_1b
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-Public-Subnet-2"
  }
}

#----------------------------------------------------
# Public Route Table
#----------------------------------------------------

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = var.alltraffic
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name}-PublicRT"
  }
}

#----------------------------------------------------
# Public Route Table Association - Subnet 1
#----------------------------------------------------

resource "aws_route_table_association" "publicRTA1" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.publicRT.id
}

#----------------------------------------------------
# Public Route Table Association - Subnet 2
#----------------------------------------------------

resource "aws_route_table_association" "publicRTA2" {
  subnet_id      = aws_subnet.publicsubnet2.id
  route_table_id = aws_route_table.publicRT.id
}

#----------------------------------------------------
# Security Group
#----------------------------------------------------

resource "aws_security_group" "websg" {
  name   = "web-sg"
  vpc_id = aws_vpc.myvpc.id

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.alltraffic]
  }

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.alltraffic]
  }

  # Outbound
  egress {
    description = "All Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.alltraffic]
  }

  tags = {
    Name = "${local.name}-Web-SG"
  }
}

#----------------------------------------------------
# S3 Bucket
#----------------------------------------------------

resource "aws_s3_bucket" "mybucket" {
  bucket = var.bkt
}

#----------------------------------------------------
# EC2 Instance - Web Server
# Public Subnet 1
#----------------------------------------------------

resource "aws_instance" "jumpserver" {
  ami           = var.i_ami
  instance_type = var.i_type
  subnet_id     = aws_subnet.publicsubnet.id

  vpc_security_group_ids = [
    aws_security_group.websg.id
  ]

  user_data = file("jump_userdata.sh")

  tags = {
    Name = "${local.name}-Web-Server"
  }
}

#----------------------------------------------------
# EC2 Instance - DB Server
# Public Subnet 2
#----------------------------------------------------

resource "aws_instance" "dbserver" {
  ami           = var.i_ami
  instance_type = var.i_type
  subnet_id     = aws_subnet.publicsubnet2.id

  vpc_security_group_ids = [
    aws_security_group.websg.id
  ]

  user_data = file("db_userdata.sh")

  tags = {
    Name = "${local.name}-DB-Server"
  }
}

#----------------------------------------------------
# Application Load Balancer
#----------------------------------------------------

resource "aws_lb" "myalb" {
  name               = "${local.name}-ALB"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.websg.id
  ]

  # Both subnets are PUBLIC
  subnets = [
    aws_subnet.publicsubnet.id,
    aws_subnet.publicsubnet2.id
  ]

  tags = {
    Name = "${local.name}-ALB"
  }
}

#----------------------------------------------------
# Target Group
#----------------------------------------------------

resource "aws_lb_target_group" "tg" {
  name     = "${local.name}-App-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

#----------------------------------------------------
# Target Group Attachment - Web Server
#----------------------------------------------------

resource "aws_lb_target_group_attachment" "tga1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.jumpserver.id
  port             = 80
}

#----------------------------------------------------
# Target Group Attachment - DB Server
#----------------------------------------------------

resource "aws_lb_target_group_attachment" "tga2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.dbserver.id
  port             = 80
}

#----------------------------------------------------
# ALB Listener
#----------------------------------------------------

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
