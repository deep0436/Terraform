output "vpc_output" {
  value = [
    module.vpc.vpc_details.arn,
    module.vpc.id,
    module.vpc.vpc_details.Name
  ]
}

output "ec2_output" {
  value = [
    module.ec2.ec2_details.id,
    module.ec2.ec2_details.subnet,
    module.ec2.ec2_details.Name
  ]
}

output "S3" {
  value = [
    module.s3.bucket,
    module.s3.id,
    module.s3.region,
    module.s3.acl
  ]
}