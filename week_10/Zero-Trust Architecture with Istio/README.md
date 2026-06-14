# Zero-Trust Architecture with Istio

Overview
--------
This project demonstrates how to implement a zero-trust architecture inside a Kubernetes cluster using Istio. You will install Istio, enable automatic sidecar injection, deploy a simple Flask application and Redis, enforce strict mTLS using Istio's PeerAuthentication, and verify that non-mesh (intruder) pods are blocked from accessing services.

Prerequisites
-------------
- A working Kubernetes cluster (Minikube, Kind, or a managed cluster).
- `kubectl` configured to talk to your cluster.
- `istioctl` installed on your workstation. See the official Istio docs: https://istio.io/latest/docs/setup/getting-started/

Quick steps
-----------
1. Install Istio onto your cluster (basic profile):

```bash
# Example (Linux/macOS): download and install the latest Istio, then run:
istioctl install --set profile=default -y

# On Windows you can use the istioctl binary downloaded from the Istio release page
# or a package manager if available, then run the same `istioctl install` command.
```

2. Enable automatic sidecar injection in the namespace where you will deploy:

```bash
kubectl label namespace default istio-injection=enabled
```

3. Deploy the Flask app and Redis (example manifest in this project):

```bash
kubectl apply -f app-stack.yaml
kubectl get pods
```

You should now see each application pod running two containers: your application container and an Istio Envoy sidecar.

Enforce mTLS (PeerAuthentication)
---------------------------------
Create and apply a PeerAuthentication resource to require mTLS in the namespace. Example `peer-authentication.yaml`:

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default-strict
  namespace: default
spec:
  mtls:
    mode: STRICT
```

Apply it with:

```bash
kubectl apply -f peer-authentication.yaml
kubectl get peerauthentications.security.istio.io -n default
```

After this, Istio will require mutual TLS for pod-to-pod communication in the `default` namespace. Traffic from workloads that do not have a sidecar (and thus no Istio identity/certificates) will be rejected.

Verify using an intruder pod
---------------------------
Create a pod that does NOT have the Istio sidecar and attempt to curl the Flask service. Example `intruder-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: intruder-client
  namespace: default
  labels:
    app: intruder
  annotations:
    sidecar.istio.io/inject: 'false'
spec:
  containers:
  - name: curl
    image: curlimages/curl:8.1.0
    command: ["sleep", "3600"]
  restartPolicy: Never
```

Apply and exec into the intruder pod:

```bash
kubectl apply -f intruder-pod.yaml
kubectl exec -it intruder-client -- sh
# From inside the intruder pod try to curl the internal service
curl http://flask-service:5000/
```

Expected result: the request fails because the intruder pod does not present valid Istio certificates.

Useful commands
---------------
- List pods and see sidecar containers: `kubectl get pods -o wide` / `kubectl describe pod <pod-name>`
- Check Istio configuration: `kubectl get peerauthentications.security.istio.io -n default`
- Inspect Envoy sidecar logs: `kubectl logs <pod-name> -c istio-proxy`
- Verify service reachability from a sidecar-injected pod: `kubectl exec -it <pod-with-sidecar> -- curl http://flask-service:5000/`

Notes
-----
- This repository contains a `WALKTHROUGH.md` with step-by-step screenshots and explanations for each action. Follow it for a guided lab experience.
- Adjust YAML filenames and image tags to match your local setup (Minikube users often use `imagePullPolicy: Never` and build images locally).

Files
-----
- WALKTHROUGH: See [week_10/Zero-Trust%20Architecture%20with%20Istio/WALKTHROUGH.md](week_10/Zero-Trust%20Architecture%20with%20Istio/WALKTHROUGH.md)
- Example manifests included: `app-stack.yaml`, `peer-authentication.yaml`, `intruder-pod.yaml` (modify if necessary)

Next steps
----------
- Run the quick steps above in your cluster and confirm pods show two containers each.
- Apply the `PeerAuthentication` and verify that an intruder pod cannot reach the Flask service.

If you want, I can also: provide the example YAML files in this folder, or run through the verification commands and expected outputs.