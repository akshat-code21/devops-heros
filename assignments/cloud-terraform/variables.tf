variable "aws_region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix applied to all resources created in this project."
  type        = string
  default     = "cloud-terraform-demo"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet."
  type        = string
  default     = "ap-south-1a"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (Ubuntu 22.04 LTS in ap-south-1)."
  type        = string
  default     = "ami-00bb6a80f01f03502"
}
