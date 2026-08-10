#----------------------
# VPC
#----------------------

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.cidr_block
  vpc_name = var.vpc_name
  subnet_cidr = var.cidr_block
}

#----------------------
# S3
#----------------------

module "s3" {
  source = "./modules/s3"
  bkt_name = var.bkt
  region = var.i_region
  acl = var.acl
}

#----------------------
# EC2-instance
#----------------------

module "ec2" {
  source = "./modules/ec2"
  subnet_id = module.vpc.subnet_details.id
  image = var.image
  i_type = var.i_type
  i_name = var.i_name 
}
