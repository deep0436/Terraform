output "vpc_output" {
  value = [
    module.vpc.vpc_details.arn,
    module.vpc.vpc_details.id,
    module.vpc.vpc_details.Name
  ]
}

output "ec2_output" {
  value = [
    module.ec2.ec2_details.ip,
    module.ec2.ec2_details.subnet,
    module.ec2.ec2_details.Name
  ]
}

output "S3" {
  value = [
    module.s3.s3-bkt-details.bucket,
    module.s3.s3-bkt-details.id,
    module.s3.s3-bkt-details.region,
    module.s3.s3-bkt-details.acl
  ]
}