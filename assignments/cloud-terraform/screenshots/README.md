# Screenshots Guide & Checklist

This directory holds the verification screenshots for **Session 19: Cloud & Terraform in Action**.

---

## Screenshot Inventory

| # | Filename | Type | Description / What to Capture | Source / Location |
|---|---|---|---|---|
| **01** | `01-terraform-init.png` | Terminal | `terraform init` output showing successful plugin installation (`hashicorp/aws`, `hashicorp/random`) | Terminal |
| **02** | `02-terraform-validate.png` | Terminal | `terraform validate` displaying `Success! The configuration is valid.` | Terminal |
| **03** | `03-terraform-plan.png` | Terminal | `terraform plan` summary displaying `Plan: 12 to add, 0 to change, 0 to destroy.` | Terminal |
| **04** | `04-terraform-apply.png` | Terminal | `terraform apply -auto-approve` output displaying completion (`Apply complete! Resources: 12 added...`) and outputs | Terminal |
| **05** | `05-terraform-state-list.png` | Terminal | `terraform state list` showing all managed resources in local state | Terminal |
| **06** | `06-terraform-output.png` | Terminal | `terraform output` displaying structured output attributes | Terminal |
| **07** | `07-web-browser-verification.png` | Browser | Web browser visiting `http://<ec2_public_ip>` showing the responsive session dashboard | Web Browser |
| **08** | `08-aws-vpc-console.png` | AWS Console | VPC list showing `cloud-terraform-demo-vpc` with IPv4 CIDR `10.0.0.0/16` | [AWS VPC Console](https://ap-south-1.console.aws.amazon.com/vpc/home?region=ap-south-1#vpcs:) |
| **09** | `09-aws-subnet-console.png` | AWS Console | Subnets list showing `cloud-terraform-demo-public-subnet` in `ap-south-1a` | [AWS Subnets Console](https://ap-south-1.console.aws.amazon.com/vpc/home?region=ap-south-1#subnets:) |
| **10** | `10-aws-security-group.png` | AWS Console | Security Group details showing inbound rules (Port 80 HTTP, Port 22 SSH) | [AWS Security Groups Console](https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#SecurityGroups:) |
| **11** | `11-aws-ec2-console.png` | AWS Console | EC2 instance `cloud-terraform-demo-web-server` running with public IPv4 assigned | [AWS EC2 Console](https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#Instances:) |
| **12** | `12-aws-s3-console.png` | AWS Console | S3 buckets list showing `cloud-terraform-demo-bucket-<suffix>` with Versioning and Encryption enabled | [AWS S3 Console](https://s3.console.aws.amazon.com/s3/home?region=ap-south-1) |
| **13** | `13-terraform-destroy.png` | Terminal | `terraform destroy -auto-approve` output confirming `Destroy complete! Resources: 12 destroyed.` | Terminal |

---

## How to Capture the AWS Console Screenshots

### 1. VPC Console (`08-aws-vpc-console.png`)
* **URL:** `https://ap-south-1.console.aws.amazon.com/vpc/home?region=ap-south-1#vpcs:`
* **Steps:**
  1. Open AWS Management Console and ensure region is **Asia Pacific (Mumbai) ap-south-1**.
  2. In the search bar, search for **VPC**.
  3. Under **Your VPCs**, filter or look for `cloud-terraform-demo-vpc`.
  4. Select the VPC checkbox to show details at the bottom (VPC ID, State: Available, IPv4 CIDR: `10.0.0.0/16`).
  5. Take a screenshot showing both the table and details pane.

### 2. Subnet Console (`09-aws-subnet-console.png`)
* **URL:** `https://ap-south-1.console.aws.amazon.com/vpc/home?region=ap-south-1#subnets:`
* **Steps:**
  1. In the VPC Console left sidebar, click **Subnets**.
  2. Filter by `cloud-terraform-demo-public-subnet`.
  3. Select the subnet and verify Availability Zone is `ap-south-1a` and CIDR is `10.0.1.0/24`.
  4. Take a screenshot.

### 3. Security Group Console (`10-aws-security-group.png`)
* **URL:** `https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#SecurityGroups:`
* **Steps:**
  1. Go to **EC2 Console** -> **Network & Security** -> **Security Groups**.
  2. Select `cloud-terraform-demo-web-sg`.
  3. In the lower pane, click the **Inbound rules** tab.
  4. Ensure rules for Port 80 (HTTP) and Port 22 (SSH) are clearly visible.
  5. Take a screenshot.

### 4. EC2 Console (`11-aws-ec2-console.png`)
* **URL:** `https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#Instances:`
* **Steps:**
  1. Go to **EC2 Console** -> **Instances**.
  2. Select `cloud-terraform-demo-web-server`.
  3. Verify Instance State is **Running**, and check the **Public IPv4 address** in the Details tab.
  4. Take a screenshot.

### 5. S3 Console (`12-aws-s3-console.png`)
* **URL:** `https://s3.console.aws.amazon.com/s3/home?region=ap-south-1`
* **Steps:**
  1. Go to **S3 Console**.
  2. In the Buckets table, search for `cloud-terraform-demo-bucket-`.
  3. Click on the bucket name, click **Properties** tab.
  4. Verify **Bucket Versioning: Enabled** and **Default encryption: Server-side encryption with Amazon S3 managed keys (SSE-S3)**.
  5. Take a screenshot.
