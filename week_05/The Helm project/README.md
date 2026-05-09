# The Helm project

## Overview
This project packages a Flask application and Redis service as a professional-grade Helm Chart. The Chart is designed to be generic and reusable, supporting multiple deployment environments (development and production) through conditional templating and environment-specific value files.

**Key Objective:** Create a single Chart that intelligently adapts to different deployment scenarios, including optional Redis support and environment-specific resource configurations.

## Features
✨ **Professional Helm Chart Design**
- Generic, reusable Chart supporting Flask and optional Redis
- Go template engine for dynamic configuration
- Conditional templating with `{{ if .Values.redis.enabled }}`
- Support for multiple deployment environments

🔧 **Environment Management**
- **Development Environment** (`values-dev.yaml`): 1 replica, no resource limits
- **Production Environment** (`values-prod.yaml`): 3 replicas, CPU/RAM limits, and node taints support

📦 **Flexible Deployments**
- Enable/disable Redis based on configuration
- Dynamic replica count management
- Configurable resource limits and requests
- Node taints and tolerations for production environments

## Project Structure
```
The Helm project/
├── README.md                    # This file
├── WALKTHROUGH.md              # Step-by-step guide
├── src/
│   ├── flask-deployment.yaml   # Flask Deployment template
│   ├── flask-service.yaml      # Flask Service template
│   ├── redis-deployment.yaml   # Redis Deployment template (conditional)
│   ├── redis-service.yaml      # Redis Service template (conditional)
│   ├── values-dev.yaml         # Development environment values
│   └── values-prod.yaml        # Production environment values
└── img/                        # Documentation images
```

## Prerequisites
- **Kubernetes Cluster** (e.g., Kind, Minikube, or cloud-based)
- **Helm 3.x** installed on your system
- **Docker** with access to images:
  - `jrsg/flask-app:dev` or `jrsg/flask-app:prod`
  - `redis:alpine`

## Getting Started
### 1. Install the Chart
#### For Development Environment
```bash
helm install flask-redis-dev ./src -f ./src/values-dev.yaml
```

#### For Production Environment
```bash
helm install flask-redis-prod ./src -f ./src/values-prod.yaml
```

### 2. Verify the Deployment
```bash
kubectl get deployments
kubectl get services
kubectl get pods
```

### 3. Access the Flask Application
```bash
# Port-forward to access the service
kubectl port-forward svc/flask-service 5000:5000

# Visit http://localhost:5000 in your browser
```

## Configuration
### Development Environment (`values-dev.yaml`)
Designed for local development and testing:

```yaml
replicaCount: 1                    # Single replica for dev
flask:
  image: "jrsg/flask-app:dev"      # Development image
  port: 5000
resources: {}                      # No resource limits
tolerations: []                    # No node taints
redis:
  enabled: true                    # Redis enabled
  image: "redis:alpine"
```

**Use Case:** Quick local testing, minimal resource consumption

### Production Environment (`values-prod.yaml`)
Designed for high-availability production deployments:

```yaml
replicaCount: 3                    # Three replicas for HA
flask:
  image: "jrsg/flask-app:prod"     # Production image
  port: 5000
resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
  requests:
    cpu: "250m"
    memory: "256Mi"
tolerations:
  - key: "environment"
    operator: "Equal"
    value: "produccion"
    effect: "NoSchedule"           # Taints for prod nodes
redis:
  enabled: true
  image: "redis:alpine"
```

**Use Case:** Production deployments with high availability and resource constraints

## Key Template Features
### Conditional Redis Deployment
The Redis deployment is wrapped in a conditional statement:

```yaml
{{- if .Values.redis.enabled }}
  # Redis Deployment content
{{- end }}
```

If `redis.enabled` is set to `false` in your values file, the Redis deployment is completely omitted from the Helm release.

### Dynamic Replica Count
```yaml
replicas: {{ .Values.replicaCount }}
```

The replica count is read from the values file, allowing environment-specific scaling without modifying templates.

### Resource Management
```yaml
resources:
  {{- toYaml .Values.resources | nindent 12 }}
```

- **Development:** Empty resources block (`{}`) results in no limits
- **Production:** CPU and memory limits/requests are applied with correct YAML indentation

### Taints and Tolerations
```yaml
{{- with .Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
{{- end }}
```

Production deployments can tolerate node taints, enabling workload-specific node assignment.

## Advanced Usage
### Disable Redis
To deploy only the Flask application without Redis:

```bash
helm install flask-only ./src -f ./src/values-dev.yaml --set redis.enabled=false
```

### Custom Values
Create your own values file for specific scenarios:

```bash
helm install my-app ./src -f ./my-custom-values.yaml
```

### Upgrade an Existing Release
```bash
helm upgrade flask-redis-dev ./src -f ./src/values-dev.yaml
```

### Uninstall a Release
```bash
helm uninstall flask-redis-dev
```

### Dry-Run (Preview Changes)
```bash
helm install flask-redis-dev ./src -f ./src/values-dev.yaml --dry-run --debug
```

## Deployment Flow
```
┌─────────────────────────────────────────────────┐
│          Helm Install Command                   │
└─────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│    Load values-dev.yaml or values-prod.yaml     │
└─────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│   Go Template Engine Processes Templates         │
│   - Applies conditionals                         │
│   - Injects values dynamically                   │
│   - Formats YAML correctly                       │
└─────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│    Generated Kubernetes Manifests                │
│    - Flask Deployment (always)                   │
│    - Flask Service (always)                      │
│    - Redis Deployment (if enabled)               │
│    - Redis Service (if enabled)                  │
└─────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────┐
│    kubectl Apply → Kubernetes Cluster            │
└─────────────────────────────────────────────────┘
```

## Learning Outcomes
After completing this project, you'll understand:

- ✅ How to structure a professional Helm Chart
- ✅ Using Go templates with conditionals and loops
- ✅ Managing multiple environments with values files
- ✅ Dynamic YAML formatting with `toYaml` and indentation
- ✅ Implementing tolerations and taints in Helm
- ✅ Best practices for production-grade deployments
- ✅ How to create reusable, generic Charts

## Troubleshooting
### Issue: Redis pod not deploying

**Solution:** Verify `redis.enabled` is set to `true` in your values file:
```bash
helm get values <release-name>
```

### Issue: Pods not scheduling in production
**Solution:** Ensure your Kubernetes nodes have the required taints:
```bash
kubectl describe nodes | grep Taints
```

### Issue: Resource limits causing pod crashes
**Solution:** Check resource requests/limits in `values-prod.yaml` match your cluster capacity:
```bash
kubectl describe nodes
```

### Issue: Template rendering errors
**Solution:** Validate the manifest before deployment:
```bash
helm template <release-name> ./src -f ./src/values-prod.yaml
```

## References
- [Helm Official Documentation](https://helm.sh/docs/)
- [Go Template Language](https://golang.org/pkg/text/template/)
- [Kubernetes Tolerations and Taints](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
- [Kubernetes Resource Requests and Limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

## Author Notes
This project demonstrates professional Helm practices used in enterprise environments. The separation of concerns (development vs. production), conditional templating, and environment-specific configurations are industry-standard patterns that scale well from development teams to large organizations.

For detailed step-by-step instructions on building this Chart from scratch, see [WALKTHROUGH.md](WALKTHROUGH.md).

## License
This project is part of the "Road to DevOps-Cloud" learning path.