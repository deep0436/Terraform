terraform {
  backend "s3" {
    bucket = "terraform-vpc-with-alb-project" #var.bkt
    key = "prod/terraform.tfstate"
    region = "ap-south-1"
    use_use_lockfile = true    
  }
}