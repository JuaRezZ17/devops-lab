# AWS Foundation Module

## Overview
This project demonstrates Infrastructure as Code (IaC) best practices by converting manual AWS Console clicks into professional, modularized, and versioned Terraform code. Build a production-ready, high-availability architecture from scratch with a single command.

**Key Objective:** Deploy a complete AWS infrastructure stack including a VPC with public/private subnets, security groups, an Application Load Balancer (ALB), and an Auto Scaling Group (ASG) with a single `terraform apply -auto-approve` command in under 3 minutes.

## Objective
Translate Week 6's manual ALB + Auto Scaling setup into production-grade Infrastructure as Code:
- Define a VPC with 2 public subnets and 2 private subnets across multiple Availability Zones
- Configure Internet Gateway and route tables to enable public/private subnet routing
- Create security groups following the principle of least privilege (ALB-to-world, EC2-from-ALB-only)
- Implement Launch Template with bootstrap user data script to install a web server
- Deploy Auto Scaling Group with desired capacity of 2 across public subnets
- Place an Application Load Balancer in front of the ASG for traffic distribution

## What You Will Learn
**Infrastructure as Code Mastery**
- Structure Terraform code into logical, reusable modules (`provider.tf`, `network.tf`, `security.tf`, `compute.tf`, `outputs.tf`)
- Use `filebase64()` function to securely inject bootstrap scripts into Launch Templates
- Implement dynamic security group references for implicit dependencies

**AWS Architecture Patterns**
- Multi-AZ design for high availability and fault tolerance
- Public/private subnet segmentation for security
- Load balancing with automatic instance registration
- Auto Scaling for dynamic capacity management

**Security Best Practices**
- Implement layered security groups (ALB allows world, EC2 allows ALB only)
- Enable DNS hostnames for proper naming resolution
- Use security group IDs instead of CIDR blocks for implicit dependencies

**Infrastructure Automation**
- Bootstrap instances with `user_data` scripts to install web servers
- Enable automatic public IP assignment on instance launch
- Implement target group health checks for self-healing infrastructure

## Resources Created
### Networking
- **VPC** - Custom VPC with DNS support enabled
- **Public Subnets** - 2 subnets with automatic public IP assignment
- **Private Subnets** - 2 subnets for internal-only resources
- **Internet Gateway** - Enables public subnet internet connectivity
- **Route Tables** - Separate route tables for public and private subnets with appropriate routes

### Security
- **ALB Security Group** - Allows inbound HTTP (port 80) from anywhere
- **EC2 Security Group** - Allows inbound HTTP only from ALB security group
- Both security groups allow all outbound traffic

### Compute & Load Balancing
- **Launch Template** - Amazon Linux 2 with user data script to install Apache web server
- **Auto Scaling Group** - Deployed across 2 public subnets (Desired=2, Min=2, Max=4)
- **Application Load Balancer** - Internet-facing ALB with health checks
- **Target Group** - Registers ASG instances for traffic distribution

## Project Structure
```
week_07/AWS Foundation Module/
├── README.md                 # This file
├── WALKTHROUGH.md           # Step-by-step implementation guide
├── src/
│   ├── provider.tf          # AWS provider configuration
│   ├── network.tf           # VPC, subnets, Internet Gateway, route tables
│   ├── security.tf          # Security groups (ALB and EC2)
│   ├── compute.tf           # Launch Template, ASG, ALB, Target Group
│   ├── outputs.tf           # Output values (ALB DNS name)
│   └── userdata.sh          # Bootstrap script (web server installation)
└── img/                     # Documentation screenshots
```

## Prerequisites
- **AWS Account** with permissions to create EC2, VPC, ALB, Auto Scaling, and IAM resources
- **Terraform 1.0+** installed locally (`terraform --version`)
- **AWS CLI** configured with valid credentials (`aws configure`)
- Basic understanding of AWS networking concepts (VPC, subnets, route tables)
- Basic knowledge of Terraform syntax and resource definitions

## Quick Start
### 1. Initialize Terraform
```bash
cd src/
terraform init
```
This downloads the AWS provider plugin and prepares the Terraform working directory.

### 2. Plan the Infrastructure
```bash
terraform plan
```
Review the planned resource creation to ensure everything looks correct.

### 3. Apply the Configuration
```bash
terraform apply -auto-approve
```
This command deploys the entire infrastructure in under 3 minutes. The `-auto-approve` flag skips the manual approval prompt.

### 4. Access Your Application
After deployment, Terraform outputs the ALB DNS name. Copy it and paste into your browser:
```
http://<alb-dns-name>
```
Refresh the page multiple times to see the hostname change — this proves the load balancer is routing traffic across different instances.

### 5. Destroy the Infrastructure
When testing is complete, remove all resources to avoid AWS charges:
```bash
terraform destroy
```

## Key Configuration Highlights
### Network Segmentation
```terraform
enable_dns_hostnames = true          # Essential for proper DNS resolution
map_public_ip_on_launch = true       # Auto-assign public IPs to public subnet instances
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main_igw.id
}  # The golden rule: turns a subnet into "public"
```

### Security Group Chaining
```terraform
ingress {
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_groups = [aws_security_group.alb_sg.id]  # Only ALB can reach EC2s
}
```

### Bootstrap Script Injection
```terraform
user_data = filebase64("${path.module}/userdata.sh")  # Terraform encodes script in base64 (AWS requirement)
```

### ASG-ALB Integration
```terraform
target_group_arns = [aws_lb_target_group.flask_tg.arn]  # Auto-registers new instances
```

## Validation
### Health Check Verification
1. In the AWS Console, navigate to EC2 → Load Balancers → Target Groups
2. Verify all targets show "Healthy" status
3. Check "Registered targets" count equals desired ASG capacity (2)

### High-Availability Test
1. Open the ALB DNS in your browser and refresh multiple times
2. Observe the hostname change — each refresh routes to a different instance
3. In the EC2 console, terminate one instance from the ASG
4. Watch the ASG Activity tab — a new instance will launch automatically to maintain desired capacity
5. The ALB's health check will automatically detect the new instance and route traffic to it

### Traffic Distribution Verification
```bash
# Monitor ALB access logs in real-time
watch -n 1 'aws elbv2 describe-target-health --target-group-arn <tg-arn> --region us-east-1'
```

## Troubleshooting
### Error: "Route53 DNS name not resolving"
**Cause:** DNS hostnames not enabled on VPC  
**Solution:** Ensure `enable_dns_hostnames = true` is set in your VPC resource

### Instances Stay in "Pending" State
**Cause:** Missing route to Internet Gateway in public subnet  
**Solution:** Verify route table has entry: `0.0.0.0/0 → Internet Gateway ID`

### ALB Health Checks Failing
**Cause:** Security group not allowing traffic from ALB  
**Solution:** Verify EC2 security group has inbound rule: `Port 80 from ALB Security Group ID`

### User Data Script Not Executing
**Cause:** Script permissions or incorrect encoding  
**Solution:** 
- Verify script starts with `#!/bin/bash` (shebang)
- Check EC2 system logs in the AWS Console for errors
- Use `filebase64()` function for proper base64 encoding

### Terraform State Lock Issues
**Cause:** Previous Terraform run didn't complete cleanly  
**Solution:** 
```bash
terraform force-unlock <LOCK_ID>
# Or remove the lock file (if using local state):
rm .terraform.tfstate.lock.hcl
```

## Performance Metrics
- **Deployment Time:** Under 3 minutes with `terraform apply -auto-approve`
- **Instance Boot Time:** ~60 seconds for full availability through ALB health checks
- **Load Balancer DNS Resolution:** <100ms (DNS cached)
- **Cross-AZ Failover Time:** ~30 seconds (ASG detects and launches replacement)

## Production Considerations
**Security Enhancements**
- Add AWS Secrets Manager integration for sensitive data
- Implement AWS Systems Manager Session Manager for secure shell access
- Enable VPC Flow Logs for network traffic monitoring
- Use AWS Key Management Service (KMS) for encrypted outputs

**Monitoring & Logging**
- Enable CloudWatch detailed monitoring on EC2 instances
- Configure ALB access logs to S3 bucket
- Set up CloudWatch alarms for ASG metrics (CPU, memory, network)
- Implement distributed tracing with AWS X-Ray

**Advanced Features**
- Implement blue-green deployment strategy with Route 53 traffic policies
- Add AWS Auto Scaling target tracking for dynamic scaling policies
- Integrate with AWS CodePipeline for automated deployments
- Implement Terraform state locking with S3 + DynamoDB

## GitHub Best Practices
**Version Control Checklist**
- Include `.gitignore` to exclude `terraform.tfstate`, `.terraform/`, and `.env` files
- Add comprehensive `README.md` (this file) documenting every resource
- Include `WALKTHROUGH.md` for step-by-step learning
- Tag releases using semantic versioning (e.g., `v1.0.0-aws-foundation`)
- Include a `LICENSE` file (MIT, Apache 2.0, etc.)

## References
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS EC2 Auto Scaling Documentation](https://docs.aws.amazon.com/autoscaling/)
- [AWS Application Load Balancer Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)

For detailed step-by-step implementation with screenshots, see [WALKTHROUGH.md](WALKTHROUGH.md)