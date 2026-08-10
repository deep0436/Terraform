output "ALB_DNS" {
  value = aws_lb.myalb.dns_name
}

output "Jump_instance_details" {
  value = [aws_instance.jumpserver.id,aws_instance.jumpserver.tags.Name,aws_instance.jumpserver.public_ip]
}

output "DB_instance_details" {
  value = [aws_instance.dbserver.id,aws_instance.dbserver.tags.Name,aws_instance.dbserver.public_ip]
}
