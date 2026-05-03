# TLS y Nginx Ingress
This project demonstrates how to set up TLS encryption for a Flask application deployed on Kubernetes using Kind, with Nginx Ingress Controller handling traffic routing and SSL termination.

## Overview
The project involves:
- Installing the official Nginx Ingress Controller for Kind
- Generating self-signed TLS certificates using OpenSSL
- Creating a Kubernetes TLS Secret
- Configuring an Ingress resource to route HTTPS traffic to the Flask service
- Setting up a fake DNS entry for local testing

## Prerequisites
- Kind (Kubernetes in Docker)
- kubectl
- OpenSSL
- A running Kind cluster with the Flask application deployed (see previous weeks for setup)

## Project Structure
- `WALKTHROUGH.md`: Step-by-step guide to complete the project
- `src/`: Contains Kubernetes manifests
  - `flask-deployment.yaml`: Flask app deployment
  - `flask-service.yaml`: ClusterIP service for Flask
  - `ingress.yaml`: Ingress configuration with TLS
  - `kind-config.yaml`: Kind cluster configuration
- `img/`: Screenshots and diagrams

## Steps Summary
1. Install Nginx Ingress Controller for Kind
2. Generate self-signed TLS certificate and key using OpenSSL
3. Create a Kubernetes TLS Secret
4. Configure and apply the Ingress resource
5. Update local `/etc/hosts` for DNS resolution
6. Access the application at `https://myapp.local`

For detailed instructions, refer to [WALKTHROUGH.md](WALKTHROUGH.md).

## Verification
After setup, navigate to `https://myapp.local` in your browser. Accept the self-signed certificate warning to view your TLS-protected Flask application.