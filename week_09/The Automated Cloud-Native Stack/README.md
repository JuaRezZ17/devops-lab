# The Automated Cloud-Native Stack

## Project Overview
This project represents the pinnacle of infrastructure automation and GitOps maturity. You will orchestrate a complete, production-grade deployment pipeline by combining **Terraform Infrastructure as Code** with **ArgoCD GitOps orchestration**. The result: a fully automated cloud-native stack where infrastructure provisioning, application deployment, and continuous updates are all managed through Git pushes and declarative configuration files.

**Key Objective:** Build an EKS cluster where Terraform automatically installs ArgoCD, configure applications through Git repositories, and achieve 100% CLI-free deployment updates through automated GitOps synchronization.

## Objective
Master the complete automation lifecycle by bringing together technologies from previous weeks:

1. **Infrastructure Layer (Terraform):** Provision an EKS cluster with Terraform and automatically install ArgoCD using the `helm_release` resource
2. **Application Layer (Helm + ArgoCD):** Deploy your Helm Chart from Week 5 as a GitOps-managed application
3. **Continuous Deployment:** Push Git changes to `values.yaml` and watch your cluster auto-update without any manual CLI commands

## What You Will Learn
### Infrastructure as Code Excellence
- Integrate Terraform with Kubernetes using the Helm provider
- Automate Helm chart installations during infrastructure provisioning
- Bridge IaC and container orchestration in a single Terraform workflow
- Understand Terraform `depends_on` for proper resource creation ordering

### GitOps Principles
- Design applications as Git-driven configuration (Git as source of truth)
- Implement continuous reconciliation between Git state and cluster state
- Enable declarative, auditable deployments with full version control
- Understand push-based (Terraform) vs pull-based (ArgoCD) deployment models

### End-to-End Automation
- Eliminate manual CLI deployments (`kubectl apply` is strictly forbidden)
- Implement automated synchronization triggered by Git commits
- Measure GitOps deployment latency from push to running application
- Establish audit trails for all infrastructure and application changes

### Production Deployment Patterns
- EKS cluster provisioning with best practices (multi-AZ, managed node groups)
- ArgoCD High Availability configuration
- Secure credential management for Git repository access
- Port forwarding for secure ArgoCD UI access

## Project Structure
```
week_09/
└── The Automated Cloud-Native Stack/
    ├── README.md                          # This file
    ├── WALKTHROUGH.md                     # Step-by-step implementation guide
    ├── img/                               # Walkthrough screenshots
    └── src/
        ├── terraform.tfvars               # Terraform variables (customize here)
        ├── versions.tf                    # Terraform and provider versions
        ├── provider.tf                    # AWS and Helm provider configuration
        ├── variables.tf                   # Variable definitions
        ├── main.tf                        # VPC, EKS cluster, and ArgoCD installation
        ├── outputs.tf                     # Useful outputs (kubectl config, port forward commands)
        │
        ├── helm/                          # Helm Chart (from Week 5)
        │   └── sample-app/
        │       ├── Chart.yaml             # Chart metadata
        │       ├── values.yaml            # Default values (image tag controlled here)
        │       ├── values-dev.yaml        # Development overrides
        │       ├── values-prod.yaml       # Production overrides
        │       └── templates/
        │           ├── deployment.yaml    # Kubernetes Deployment template
        │           └── service.yaml       # Kubernetes Service template
        │
        └── applications.yaml              # ArgoCD Application resource (references your Helm chart)
```

## Prerequisites
- AWS Account with appropriate permissions (EKS, EC2, IAM, VPC, Elastic Load Balancer)
- AWS CLI configured with valid credentials (`aws configure`)
- Terraform >= 1.5 installed locally
- kubectl installed and configured
- Helm 3.x installed
- Git installed and SSH key configured with GitHub (for ArgoCD Git access)
- Helm Chart from Week 5 uploaded to a GitHub repository
- Basic understanding of Kubernetes, Terraform, Helm, and Git

## Key Components
### Terraform Configuration
- **VPC Module:** Multi-AZ VPC with public/private subnets, NAT Gateway for egress
- **EKS Cluster:** Managed Kubernetes control plane (version 1.35)
- **Managed Node Groups:** t3.small instances (configurable) for running workloads
- **Helm Provider:** Configured to target the EKS cluster post-creation
- **ArgoCD Installation:** Helm release deployed automatically within the cluster

### ArgoCD Integration
- **Repository:** Points to your GitHub repository containing Helm charts
- **Automatic Synchronization:** Watches Git repository for changes and applies them to the cluster
- **Server Service:** ClusterIP (internal access only via port forwarding)
- **Default Credentials:** `admin` user with randomly generated password

### Helm Chart Application
- **Chart Name:** `sample-app` (from Week 5)
- **Replicas:** Controlled via `values.yaml`
- **Image:** Nginx (1.27.5 by default, configurable)
- **Service:** Exposed within the cluster via ArgoCD-managed LoadBalancer

## Workflow Overview
### Phase 1: Prepare Your Git Repository
```bash
# Structure: your-infra-repo/
# ├── terraform/
# │   ├── main.tf
# │   ├── variables.tf
# │   ├── versions.tf
# │   └── outputs.tf
# └── helm-charts/
#     └── sample-app/
#         ├── Chart.yaml
#         ├── values.yaml
#         └── templates/
```

### Phase 2: Deploy Infrastructure with Terraform
```bash
cd src/

# Initialize Terraform (downloads providers and modules)
terraform init

# Review planned infrastructure changes
terraform plan

# Provision EKS cluster and install ArgoCD automatically
terraform apply
```

**What happens automatically:**
1. VPC with public/private subnets is created
2. EKS cluster control plane is provisioned
3. Managed node group scales up
4. ArgoCD Helm chart is deployed to the cluster
5. ArgoCD is ready to manage applications

### Phase 3: Configure ArgoCD
```bash
# Configure kubectl to access your new cluster
aws eks update-kubeconfig --region eu-south-2 --name devops-cluster

# Forward ArgoCD UI to localhost:8080
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Retrieve ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
```

### Phase 4: Create ArgoCD Application
**UI Steps:**
1. Visit `http://localhost:8080` and login with `admin`
2. Create New Application:
   - **Name:** `sample-app`
   - **Repository URL:** `https://github.com/YOUR-USERNAME/YOUR-INFRA-REPO`
   - **Path:** `helm-charts/sample-app/`
   - **Destination Cluster:** `https://kubernetes.default.svc`
   - **Destination Namespace:** `default`
   - **Sync Policy:** Automatic (enables GitOps)

### Phase 5: Enable GitOps Deployments
**Now your CLI is locked away! 🔐**
- All updates must go through Git
- Edit `values.yaml` in your repository
- Commit and push to GitHub
- ArgoCD automatically detects and applies changes within seconds

**Test it:**
```bash
# In your repository, modify helm-charts/sample-app/values.yaml
# Change: tag: "1.27.5" → tag: "latest"
# Commit and push

git add helm-charts/sample-app/values.yaml
git commit -m "Update nginx version to latest"
git push

# Watch ArgoCD detect the change (30-60 seconds typical)
# Monitor: kubectl get pods -w
```

### Phase 6: Cleanup
```bash
cd src/

# Delete all AWS resources provisioned by Terraform
terraform destroy

# Confirm when prompted
# This destroys:
# - EKS cluster
# - Node groups
# - VPC and subnets
# - Elastic Load Balancers
# - All associated IAM roles and security groups
```

⚠️ **IMPORTANT:** Always run `terraform destroy` when finished to avoid unexpected AWS charges!

## GitOps Performance Metrics
Document the following for your walkthrough:
1. **Time to create infrastructure:** Record time from `terraform apply` to cluster ready
2. **Time to ArgoCD readiness:** How long after cluster creation until ArgoCD UI is accessible
3. **Time to application sync:** Measure duration from `git push` to updated pods running
4. **Typical GitOps sync interval:** Default ArgoCD polling frequency

## Terraform Variables (Customize in `terraform.tfvars`)
```hcl
aws_region           = "eu-south-2"              # AWS region (Ireland)
cluster_name         = "devops-cluster"          # EKS cluster name
instance_type        = "t3.small"                # EC2 node instance type
desired_size         = 1                         # Initial node count
argocd_version       = "latest"                  # ArgoCD Helm chart version
```

## Useful Commands
### Infrastructure Management
```bash
terraform init        # Initialize Terraform working directory
terraform plan        # Preview infrastructure changes
terraform apply       # Provision all resources
terraform destroy     # Delete all resources
terraform state list  # View current resources
```

### Kubernetes Cluster Access
```bash
# Update kubeconfig
aws eks update-kubeconfig --region eu-south-2 --name devops-cluster

# View cluster information
kubectl cluster-info
kubectl get nodes
kubectl get ns

# Monitor ArgoCD
kubectl -n argocd get all
kubectl -n argocd logs -f deployment/argocd-server
```

### ArgoCD Access
```bash
# Port forward (access at http://localhost:8080)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# View ArgoCD applications
kubectl get applications

# Manual ArgoCD synchronization (if needed)
argocd app sync sample-app
```

### Application Monitoring
```bash
# Watch pod deployment progress
kubectl get pods -w

# View application status
kubectl describe deployment sample-app
kubectl logs -f deployment/sample-app

# Access application (if exposed)
kubectl port-forward svc/sample-app 8000:80
# Then visit http://localhost:8000
```

## For Detailed Step-by-Step Instructions
Refer to [WALKTHROUGH.md](WALKTHROUGH.md) for comprehensive instructions, screenshots, and troubleshooting tips.

## Key Takeaways
✅ **Infrastructure as Code**: Entire AWS infrastructure defined in declarative Terraform code  
✅ **GitOps Mastery**: Applications deployed through Git commits, not CLI commands  
✅ **Automation Excellence**: From infrastructure to application updates, everything is automated  
✅ **Production Ready**: Multi-AZ, managed services, high availability  
✅ **Auditability**: Complete version control history for infrastructure and applications  
✅ **Cost Awareness**: Remember to `terraform destroy` to avoid ongoing AWS charges  

## Resources
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Helm Provider Documentation](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Best Practices](https://www.weave.works/technologies/gitops/)

---

**Next Steps:** Read the [WALKTHROUGH.md](WALKTHROUGH.md) to begin implementing this project!