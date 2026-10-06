# -----------------------------------------------------------------------------
# Compute (EC2) Resources
# -----------------------------------------------------------------------------

# EC2 Web Server Instance
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Implicit Dependencies:
  # Terraform automatically infers that this instance depends on the Subnet and Security Group
  # because their resource attributes (.id) are referenced here.
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  # User Data script with template interpolation
  user_data = templatefile("${path.module}/userdata.sh.tftpl", {
    project_name   = var.project_name
    environment    = var.environment
    aws_region     = var.aws_region
    s3_bucket_name = aws_s3_bucket.app_bucket.bucket
  })

  # Explicit Dependencies:
  # Demonstrates Terraform 'depends_on' meta-argument.
  # Ensures the S3 bucket and Internet Gateway are fully provisioned before the EC2 instance is created.
  depends_on = [
    aws_s3_bucket.app_bucket,
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "${var.project_name}-web-server"
    Role = "Web"
  }
}
