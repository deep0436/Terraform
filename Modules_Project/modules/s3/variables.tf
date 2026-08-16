variable "bkt_name" {
  description = "S3 bucket name"
  type = string
  #default = "my-bkt"
}

variable "region" {
  description = "region for the S3 bucket"
  type = string
  #default = "ap-south-1"
}

variable "acl" {
  description = "The ACL for the S3 bucket"
  type        = string
}