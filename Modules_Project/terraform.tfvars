#----------------------
# backend S3 - This will not work, so hardcoded the name of bkt in backend.tf as it initializes before terraform
#----------------------
backend-bkt = "s3-tf-modules-project-demo"

#----------------------
# VPC
#----------------------

cidr_block = "192.168.0.0/16"
vpc_name = "myVPC"

#----------------------
# S3-bkt
#----------------------
bkt = "my-test-module-tf-bkt"
acl = "private"

#----------------------
# EC2-Instance
#----------------------
i_region = "ap-south-1"
i_name = "myVM"
i_type = "t3.micro"
image = "ami-035827357e3c7e810"
