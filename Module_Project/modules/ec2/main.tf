resource "aws_instance" "myinstance" {
  subnet_id = var.subnet_id
  ami = var.image
  instance_type = var.i_type
  tags = {
    Name = var.i_name
  }
}
