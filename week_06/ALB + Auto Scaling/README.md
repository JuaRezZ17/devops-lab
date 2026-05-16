# ALB + Auto Scaling

## Overview
This lab demonstrates how to deploy an Application Load Balancer (ALB) in front of an Auto Scaling Group (ASG) that uses a Launch Template. The launch template boots Amazon Linux 2023 `t2.micro` instances and runs a `UserData` script that installs a simple web server and serves a page showing the instance's local IP and Availability Zone (AZ).

## Objective
Build and validate a resilient, multi-AZ HTTP service behind an ALB:
- Create a Launch Template with Amazon Linux 2023 and a `UserData` bootstrap script.
- Create an ASG using that template and deploy across two public subnets (two AZs).
- Desired capacity = 2, min = 2, max = 4.
- Put an ALB in front of the ASG with a Target Group and health checks on port 80.

## What you will learn
- How to use a Launch Template with `UserData` to bootstrap instances
- How ASG maintains desired capacity and recovers from instance termination
- How ALB distributes traffic across AZs and uses health checks

## Resources created
- Launch Template (Amazon Linux 2023, `t2.micro`, `UserData` installs web server)
- Auto Scaling Group (2 public subnets in different AZs, Desired=2, Min=2, Max=4)
- Application Load Balancer (public) and Target Group (port 80, HTTP health check)

## Project structure
```
week_06/ALB + Auto Scaling/
├── WALKTHROUGH.md    # step-by-step implementation (console + CLI)
└── README.md         # this file
```

## Prerequisites
- An AWS account with permissions to create EC2, ALB, and Auto Scaling resources
- A VPC with at least two public subnets in separate AZs (route to an Internet Gateway)
- Optional: AWS CLI configured for command-line provisioning

## Quick start (summary)
1. Create a Launch Template that uses Amazon Linux 2023, `t2.micro`, and includes a `UserData` script to install a web server and write an HTML file showing the instance local IP and AZ.
2. Create an Auto Scaling Group using the Launch Template and select two public subnets in different AZs.
3. Set ASG capacity: Desired=2, Min=2, Max=4.
4. Create an Internet-facing ALB, a Target Group on port 80, and register the ASG with the Target Group.
5. Confirm ALB health checks are passing and access the ALB DNS name in your browser.

For exact console steps, CLI commands, and the full `UserData` script, see the detailed walkthrough: [week_06/ALB + Auto Scaling/WALKTHROUGH.md](week_06/ALB%20+%20Auto%20Scaling/WALKTHROUGH.md)

## Validation (chaos test)
- Open the ALB public DNS in a browser and refresh several times — you should see responses coming from instances in both AZs (each page shows its AZ).
- In the EC2 console, select an instance created by the ASG and terminate it. Open the ASG "Activity" tab — the ASG will detect the termination and launch a replacement to maintain desired capacity.

## Troubleshooting
- Instances stay in `Pending`: verify subnets are public and have route to an Internet Gateway.
- Health checks failing: check instance security group allows inbound HTTP from the ALB and that the `UserData` script succeeded.
- ALB returns 503: ensure Target Group has healthy targets registered and check health check path/port.

## Cleanup
Delete the ASG (set desired capacity to 0 or delete group), delete the ALB, and remove the Launch Template to avoid charges.

## Next steps
- Extract the `UserData` into a standalone script file and keep it under version control.
- Create Terraform or CloudFormation templates to provision the complete stack reproducibly.
- Add CloudWatch alarms and lifecycle hooks for graceful instance termination.

---

Detailed, step-by-step instructions are available in the walkthrough: [week_06/ALB + Auto Scaling/WALKTHROUGH.md](week_06/ALB%20+%20Auto%20Scaling/WALKTHROUGH.md)
