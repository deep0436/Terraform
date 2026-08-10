resource "aws_s3_bucket" "mybkt" {
  bucket = var.bkt_name
  region = var.region
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.mybkt.id
  acl = var.acl
}
