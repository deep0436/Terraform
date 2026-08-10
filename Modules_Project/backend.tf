terraform {
  backend "s3" {
    Name = var.backend-bkt
    key = "prod/terraform.tfstate"
    use_lockfile = true
  }
}