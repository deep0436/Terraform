output "s3-bkt-details" {
  value = {
    bucket = aws_s3_bucket.mybkt.bucket,
    id = aws_s3_bucket.mybkt.id,
    region = aws_s3_bucket.mybkt.region,
    acl = aws_s3_bucket_acl
  }
}