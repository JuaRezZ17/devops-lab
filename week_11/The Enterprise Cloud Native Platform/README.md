# The Enterprise Cloud Native Platform

## Overview
This project demonstrates a full end-to-end enterprise cloud-native platform built on AWS. It combines infrastructure-as-code, GitOps, CI/CD and observability to deploy and operate a secure Python application on an AWS EKS cluster using Terraform, GitHub Actions, ArgoCD, Prometheus and Grafana Loki.

Follow the step-by-step walkthrough in `WALKTHROUGH.md` for a guided, annotated run of the exercise.

## Objectives
- Provision a secure VPC, RDS databases and an AWS EKS cluster using Terraform.
- Automatically install ArgoCD into the cluster after provisioning.
- Implement a GitHub Actions pipeline that lints, runs security checks, builds an optimized Docker image, publishes it to GitHub Packages (GHCR) and updates the GitOps repository.
- Use Kustomize + ArgoCD to detect the new image, reconcile the cluster, and perform a progressive zero-downtime rollout.
- Capture application metrics and logs automatically via Prometheus and Grafana Loki.

## Repository layout
- `WALKTHROUGH.md` — step-by-step instructions and commentary on the entire exercise.
- `infrastructure/` — Terraform code to provision the VPC, RDS, EKS and deploy ArgoCD.
- `gitops-infra/` — Kustomize base and overlays for the application manifests.
- `app-python/` — Python application source, Dockerfile and GitHub Actions CI configuration.

Note: This repository is structured for the learning lab; adapt paths and variable names when using in production.

## Prerequisites
- An AWS account with permissions to create VPCs, subnets, EKS clusters, RDS and related resources.
- `terraform` (>= 1.0) installed locally.
- `kubectl`, `aws` CLI and `helm` installed and configured.
- A GitHub account and a Personal Access Token (PAT) with `repo` and `packages` write permissions to push images and update repos.

## Quickstart (high level)
1. Initialize and apply Terraform to provision infra and install ArgoCD:

```bash
terraform init
terraform apply -auto-approve
```

2. Create two GitHub repositories: one for the application (`app-python`) and one for GitOps (`gitops-infra`). Add the GitHub PAT to the application repository secrets as `GITOPS_PAT`.

3. Push application changes to `app-python`. The GitHub Actions workflow will:
   - Run linters and security checks
   - Build an optimized Docker image tagged with `github.sha`
   - Push the image to GitHub Packages (GHCR)
   - Use `kustomize edit set image` to update the `gitops-infra` repository (Kustomize) with the new tag

4. ArgoCD (installed on the EKS cluster) watches the `gitops-infra` repo. When Kustomize changes, ArgoCD will reconcile and perform a progressive, zero-downtime rollout.

5. Install Prometheus and Grafana Loki via Helm (see `WALKTHROUGH.md`) to capture metrics and logs.

## Important Terraform notes (from the walkthrough)
- Use the EKS `exec` auth helper to run `aws eks get-token` when Terraform needs to talk to the cluster.
- Put the RDS instances in dedicated database subnets (AWS requires a DB subnet group).
- Set `single_nat_gateway = true` to reduce cost in multi-AZ setups.
- Set `cluster_endpoint_public_access = true` if you run Terraform from outside the VPC and encounter connectivity timeouts.
- Use `enable_cluster_creator_admin_permissions = true` to allow the cluster creator to operate the cluster during provisioning.
- Use `depends_on = [module.eks]` for ArgoCD installation resources to ensure the cluster and nodes are ready.
- Use `wait = false` for long-running installs (ArgoCD, Helm charts) to avoid Terraform timeouts on small test nodes.

## CI/CD and GitOps details
- The GitHub Actions pipeline builds immutable images tagged with `${{ github.sha }}` and pushes them to GHCR.
- The pipeline updates the `kustomization.yaml` in the `gitops-infra` repository with the new image tag so ArgoCD can detect the change.
- ArgoCD performs a controlled rollout using the Deployment `strategy: RollingUpdate` with `maxUnavailable: 0` and `maxSurge: 1` to achieve zero downtime.

## Observability
- Install Prometheus and Grafana Loki using the Helm commands shown in `WALKTHROUGH.md` with resource limits tuned for small test clusters.
- Configure Grafana to use Prometheus dashboards for Kubernetes metrics and Loki as a log datasource.

## Troubleshooting tips
- If ArgoCD or Helm installs fail due to resource constraints, use `--wait=false` and adjust chart components (disable dex, notifications, node-exporter, kube-state-metrics) to reduce memory usage.
- If Terraform times out reaching the cluster, verify `cluster_endpoint_public_access` and region flags for `aws eks get-token`.

## Where to look next
- Full guided steps, screenshots and the exact commands used during the exercise are in `WALKTHROUGH.md`.
- Use the Terraform outputs to retrieve ArgoCD credentials and the LoadBalancer IP.

## License & Attribution
This lab content is intended for learning and demonstration. Adapt and secure it before reuse in production.