# Kind and Distribution

## Project Overview
This project demonstrates how to deploy a Flask application backed by Redis into a local Kubernetes cluster using Kind (Kubernetes in Docker).

The setup includes:
- A Kind cluster with 1 control plane node and 2 worker nodes
- A Redis deployment and ClusterIP service named `redis-service`
- A Flask deployment with 2 replicas
- A Flask NodePort service to expose the app to the host machine

## Files
- `src/kind-config.yaml` - Kind cluster configuration with port mapping for external access
- `src/redis-deployment.yaml` - Redis Deployment manifest
- `src/redis-service.yaml` - Redis ClusterIP Service manifest
- `src/flask-deployment.yaml` - Flask Deployment manifest with `REDIS_HOST=redis-service`
- `src/flask-service.yaml` - Flask NodePort Service manifest
- `WALKTHROUGH.md` - step-by-step practice walkthrough for this lab

## Prerequisites
- Docker running on your machine
- Kind installed
- `kubectl` installed and configured
- The Flask application image must be built locally as `my-flask-app:latest`

## Deployment Steps
1. Create the Kind cluster:
   ```bash
   kind create cluster --config src/kind-config.yaml
   ```

2. Build the local Flask Docker image from your Week 3 Flask app source:
   ```bash
   docker build -t my-flask-app:latest .
   ```

3. Load the image into the Kind cluster so it can be used by Kubernetes:
   ```bash
   kind load docker-image my-flask-app:latest --name kind
   ```

4. Apply the Redis and Flask manifests:
   ```bash
   kubectl apply -f src/redis-deployment.yaml
   kubectl apply -f src/redis-service.yaml
   kubectl apply -f src/flask-deployment.yaml
   kubectl apply -f src/flask-service.yaml
   ```

## Verification
- Confirm the cluster and pods are running:
  ```bash
  kubectl get nodes
  kubectl get pods
  kubectl get services
  ```

- Access the Flask app from your browser at:
  ```bash
  http://localhost:30000
  ```

- Refresh the page multiple times or run `curl` repeatedly to verify that the visit counter increments and that the load is distributed across the Flask replicas.

## Notes
- `redis-service` is used as the Redis host inside the cluster via the `REDIS_HOST` environment variable.
- The Flask service uses `NodePort` with `nodePort: 30000` so the app is reachable from the host machine.
- `imagePullPolicy: Never` ensures Kubernetes uses the locally loaded Docker image rather than attempting to pull from a registry.
