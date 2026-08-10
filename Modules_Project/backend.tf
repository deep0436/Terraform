terraform {
  backend "s3" {
    bucket = "terraf-backend-s3-demo"
    key = "prod/terraform.tfstate"
    region = "ap-south-1"
    use_lockfile = true
  }
}
