# -----------------------------------------------------------------------------
# Terraform Outputs
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the custom VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block of the custom VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "The ID of the public subnet."
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "The ID of the web security group."
  value       = aws_security_group.web_sg.id
}

output "ec2_instance_id" {
  description = "The ID of the provisioned EC2 instance."
  value       = aws_instance.web.id
}

output "ec2_public_ip" {
  description = "The public IPv4 address of the EC2 instance."
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "The public DNS name assigned to the EC2 instance."
  value       = aws_instance.web.public_dns
}

output "web_url" {
  description = "URL to access the web application in a browser."
  value       = "http://${aws_instance.web.public_ip}"
}

output "s3_bucket_name" {
  description = "The name of the globally unique S3 bucket."
  value       = aws_s3_bucket.app_bucket.bucket
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.app_bucket.arn
}
