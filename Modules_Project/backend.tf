terraform {
  backend "s3" {
    Name = "terraf-backend-s3-demo"
    key = "prod/terraform.tfstate"
    use_lockfile = true
  }
}
