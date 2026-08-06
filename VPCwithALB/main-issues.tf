locals {
  description = "creating local variable"
  name = "My"
}

#Creating VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
  tags = {
      Name = "${local.name}-VPC"
  }
}

#Create Internet Gateway IGW
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.myvpc.id
 tags = {
    Name = "${local.name}-IGW"
 } 
}

#Attaching IGW to VPC
#resource "aws_internet_gateway_attachment" "igw" {
#  internet_gateway_id = aws_internet_gateway.igw.id
#  vpc_id = aws_vpc.myvpc.id
#}

#Creating Public subnet in AZ ap-south-1a
resource "aws_subnet" "publicsubnet" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.subnet1_cidr
  availability_zone = var.az_1a
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}-Public-Subnet"
  }
}

#Creating Private Subnet in AZ ap-south-1b
resource "aws_subnet" "privatesubnet" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.subnet2_cidr
  availability_zone = var.az_1b
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${local.name}-Private-Subnet"
  }
}

#Creating NAT Gateway NAT-GW
resource "aws_nat_gateway" "nat-gw" {
  subnet_id = aws_subnet.privatesubnet.id
  tags = {
    Name = "${local.name}-NAT-GW"
  }
}

#Creating Public Route Table
resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = var.alltraffic
    gateway_id = aws_internet_gateway.my-IGW.id
  }
  tags = {
    Name = "${local.name}-PublicRT"
  }
}

#Creating Private Route Table
resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block     = var.alltraffic
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "${local.name}-PrivateRT"
  }
}

#Associate route table to Public RT
resource "aws_route_table_association" "publicRTA" {
  route_table_id = aws_route_table.publicRT.id
  subnet_id = aws_subnet.publicsubnet.id
}

#Associate route table to Private RT
resource "aws_route_table_association" "privateRTA" {
  route_table_id = aws_route_table.privateRT
  subnet_id = aws_subnet.privatesubnet.id
}

#Creating Security Groups
resource "aws_security_group" "websg" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "From web to VPC"
    from_port = 80
    to_port = 80
    protocol = TCP
    cidr_blocks = [ var.alltraffic ]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = TCP
    cidr_blocks = [ var.alltraffic ]
  }
  
  egress {
    description = "Outbound open for all"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [ var.alltraffic ]
  }

  tags = {
    Name = "${local.name}-Web-SG"
  }
}

#Creating S3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bkt
}

#Creating EC2 instances in our created VPC
resource "aws_instance" "jumpserver" {
  ami = var.i_ami
  subnet_id = aws_subnet.publicsubnet.id
  instance_type = var.i_type  
  security_groups = [ aws_security_group.websg.id ]
  user_data = base64encode(file(jump_userdata.sh))
  tags = {
    Name = "${local.name}-Web-Server"
  }
}

#Creating EC2 instances in our created VPC
resource "aws_instance" "dbserver" {
  ami = var.i_ami
  subnet_id = aws_subnet.privatesubnet.id
  instance_type = var.i_type 
  security_groups = [ aws_security_group.websg.id ]
  user_data = base64encode(file(db_userdata.sh))
  tags = {
    Name = "${local.name}-DB-Server"
  }
}

#Creating Application Load Balancer
resource "aws_lb" "myalb" {
  internal = false
  load_balancer_type = "application"
  name = "${local.name}-ALB"
  security_groups = [ aws_security_group.websg.id ]
  subnets = [ aws_subnet.publicsubnet.id,aws_subnet.privatesubnet.id ]
  tags = {
    Name = "${local.name}-ALB"
  }
}

#Creating Target Groups
resource "aws_lb_target_group" "tg" {
  name = "${local.name}-App-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

#Attaching Load Balancer to Target group along with instance
resource "aws_lb_target_group_attachment" "tga1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.jumpserver.id
  port = 80
}

#Attaching Load Balancer to Target group along with instance
resource "aws_lb_target_group_attachment" "tga2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.dbserver.id
  port = 80
}

#Adding listener to ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type = "forward"
  }
}