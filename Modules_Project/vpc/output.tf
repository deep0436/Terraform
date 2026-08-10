output "vpc_details" {
  value = {
    arn = aws_vpc.myvpc.arn,
    id = aws_vpc.myvpc.id,
    Name = aws_vpc.myvpc.tags.Name
  }
}