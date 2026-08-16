output "vpc_details" {
  value = {
    arn = aws_vpc.myvpc.arn,
    id = aws_vpc.myvpc.id,
    Name = aws_vpc.myvpc.tags.Name
  }
}

output "subnet_details" {
  value = {
    id   = aws_subnet.mysubnet.id
    cidr = aws_subnet.mysubnet.cidr_block
  }
}