#----------------------
# backend S3
#----------------------

variable "backend-bkt" {
  type = string
}
#----------------------
# VPC
#----------------------

variable "cidr_block" {
  type = string
}

variable "vpc_name" {
  type = string
}
#----------------------
# S3-bkt
#----------------------

variable "bkt" {
  type = string
}

variable "acl" {
  type = string
}
#----------------------
# EC2-Instance
#----------------------

variable "i_region" {
  type = string
}

variable "i_type" {
  type = string
}

variable "i_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "image" {
  type = string
}