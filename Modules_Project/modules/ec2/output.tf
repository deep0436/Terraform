output "ec2_details" {
  value = {
    ip = aws_instance.myinstance.public_ip,
    subnet = aws_instance.myinstance.subnet_id,
    Name = aws_instance.myinstance.tags.Name
  }
}