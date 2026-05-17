# Deployment using eksctl

## Project Overview
This project demonstrates deploying Kubernetes applications to Amazon EKS (Elastic Kubernetes Service), a managed Kubernetes service on AWS. You'll provision a production-grade Kubernetes cluster in the cloud, deploy the Flask + Redis application from Week 5 using Helm, and expose it through AWS's managed load balancer service.

**Note:** For detailed step-by-step instructions on implementing this project, refer to the [WALKTHROUGH.md](WALKTHROUGH.md) file.

## Objective
Transition from local Kubernetes clusters (Kind) to a cloud-managed environment. Understand how AWS manages the control plane while you manage the data plane (nodes), and experience the seamless integration between Kubernetes resources and AWS services.

## The Project: EKS Cluster Deployment
### Infrastructure Setup
Launch a minimal production cluster with:
- **Managed Control Plane:** AWS handles Kubernetes master components
- **2 Managed Worker Nodes:** Using t3.medium instance types
- **Automatic Infrastructure Provisioning:** VPC, subnets, security groups, and IAM roles created automatically
- **Regional Deployment:** Distributed across availability zones for high availability

### Application Deployment
Deploy the Helm-packaged Flask + Redis application from Week 5 with:
- **Custom Configuration:** Override default values for cloud deployment
- **Service Exposure:** Transform NodePort to LoadBalancer for cloud-native access
- **Auto-Scaling:** AWS Load Balancer automatically routes traffic to healthy pods

### Cloud Integration
Experience key AWS-Kubernetes integrations:
- **Elastic Load Balancer (ELB):** AWS automatically provisions a physical load balancer when you create a LoadBalancer service
- **IAM Integration:** Worker nodes have proper IAM roles for AWS API access
- **CloudFormation:** AWS manages cluster lifecycle through CloudFormation stacks

## Project Structure
```
src/
├── custom-values.yaml  # Helm values for cloud deployment
└── (Helm chart from Week 5)
```

## Prerequisites
- AWS Account with appropriate permissions (EC2, EKS, IAM, VPC)
- AWS CLI configured with valid credentials
- eksctl installed (EKS Cluster Management Tool)
- kubectl installed and configured
- Helm installed (from Week 5)
- Docker image of Flask + Redis application
- Familiarity with Kubernetes concepts and Helm

## Installation and Setup

### 1. Install eksctl and kubectl
Download and install the official EKS CLI tool:
```bash
curl -sLO 'https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz'
tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp && rm eksctl_Linux_amd64.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
```

Verify kubectl is installed:
```bash
kubectl version --client
```

### 2. Create the EKS Cluster
Launch a minimal cluster with 2 managed nodes (takes 15-20 minutes):
```bash
eksctl create cluster \
  --name my-cloud-cluster \
  --region eu-west-1 \
  --nodegroup-name my-nodes \
  --node-type t3.medium \
  --nodes 2
```

This command automatically:
- Creates a VPC with subnets in multiple availability zones
- Configures security groups and IAM roles
- Provisions EC2 instances for worker nodes
- Updates your local kubeconfig with cluster credentials

### 3. Verify Cluster Connectivity
Confirm your kubectl can communicate with the cluster:
```bash
kubectl get nodes
```

You should see 2 worker nodes in a Ready state.

## Usage

### Deploying the Application
Create a `custom-values.yaml` file to override Helm default values for cloud deployment:
```yaml
service:
  type: LoadBalancer
  port: 80
  targetPort: 5000

replicaCount: 2

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
```

Deploy or upgrade the Helm release:
```bash
helm upgrade --install flask-redis-app ./helm-chart -f custom-values.yaml
```

### Accessing the Application
Get the LoadBalancer external IP:
```bash
kubectl get services
```

Look for the `flask-redis-app` service and note its `EXTERNAL-IP`. Access the application:
```bash
curl http://<EXTERNAL-IP>
```

Or open it in your browser. The AWS Load Balancer automatically routes traffic to your Flask pods.

## Verification and Testing

### Check Cluster Status
```bash
# View all nodes
kubectl get nodes

# View all running pods
kubectl get pods --all-namespaces

# View services and their LoadBalancer IPs
kubectl get svc
```

### Test Application Functionality
1. Access the application through the LoadBalancer IP
2. Refresh the page multiple times to verify the visit counter increments
3. Check that traffic is distributed across multiple pods:
   ```bash
   kubectl get pods -o wide
   ```

### Monitor AWS Resources
Verify the load balancer was created:
```bash
aws elbv2 describe-load-balancers --region eu-west-1
```

Check EC2 instances:
```bash
aws ec2 describe-instances --region eu-west-1
```

## Key Concepts and Learning Objectives

### Managed Kubernetes Services
- **AWS Responsibility:** Control plane (API servers, etcd, controllers)
- **Your Responsibility:** Worker nodes, application deployment, data plane
- **Benefits:** No need to manage Kubernetes infrastructure, automatic updates and patching

### Infrastructure as Code
eksctl uses CloudFormation under the hood to manage all AWS resources, making your infrastructure repeatable and versionable.

### Service Types in Production
- **ClusterIP:** Internal communication only (used for Redis service)
- **NodePort:** Exposes on all nodes (good for local development)
- **LoadBalancer:** Creates cloud provider's load balancer (production-ready)

### Helm in the Cloud
Deploy the same Helm chart across environments (local, cloud, production) by using different values files, following the Infrastructure as Code principle.

## CRITICAL CLEANUP (Do Not Skip)

**Important:** AWS resources cost money. Clean up immediately after completing the exercise:

```bash
eksctl delete cluster --name my-cloud-cluster --region eu-west-1
```

Verify cleanup in the AWS Console:
1. **CloudFormation:** Check that the EKS stack has been deleted
2. **EC2:** Confirm all instances (nodes) have terminated
3. **ELB:** Verify the load balancer has been removed
4. **VPC:** Check that associated VPC resources are cleaned up

Alternative verification using AWS CLI:
```bash
aws cloudformation describe-stacks --region eu-west-1
aws ec2 describe-instances --region eu-west-1
aws elbv2 describe-load-balancers --region eu-west-1
```

All results should show no active resources.

## Troubleshooting

### eksctl create cluster stuck or timing out
- Increase the timeout: `eksctl create cluster --timeout=50m ...`
- Check AWS CloudFormation console for errors

### kubectl cannot connect to cluster
- Verify kubeconfig: `kubectl config current-context`
- Ensure AWS credentials are configured: `aws sts get-caller-identity`

### LoadBalancer service stuck in `<pending>`
- Check service logs: `kubectl describe svc <service-name>`
- Verify IAM permissions for the worker node role

### High costs or unexpected charges
- Delete the cluster immediately: `eksctl delete cluster ...`
- Check CloudFormation for orphaned resources

## Next Steps
- Explore EKS autoscaling: `eksctl create nodegroup`
- Implement CI/CD pipelines that deploy to EKS
- Set up monitoring with CloudWatch and Prometheus
- Investigate AWS Service Mesh (App Mesh) for advanced traffic management
- Learn about EKS add-ons (VPC CNI, CoreDNS, kube-proxy)