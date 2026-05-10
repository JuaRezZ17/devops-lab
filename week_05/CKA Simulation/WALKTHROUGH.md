# CKA Simulation

## Objetive
Prepare for the Certified Kubernetes Administrator certification.

### NotReady Nodes: How to fix a failed kubelet.
When a node changes to the NotReady state, the most common culprit is the kubelet service running as a systemd daemon on that specific node. The steps to resolve this are:
1. Identify the problematic node using `kubectl get nodes` and note down its name (for this exercise, we will use ‘node01’).
2. Connect to the node via SSH: `ssh node01`.
3. Check the status of the service with `systemctl status kubelet`.
4. If the service is `failed`, investigate the cause in the logs to find out which file or configuration is failing: `journalctl -u kubelet -xe --no-pager | tail -n 50`.
5. The most common errors are:
    - **Syntax errors**
    - **Incorrect binary or missing permissions**
    - **Swap enabled**
6. Once the error has been fixed, reload systemd and start the service:
    - `systemctl daemon-reload`
    - `systemctl enable --now kubelet`
7. We verify that the status is `running` using `systemctl status kubelet`.
8. We check that the primary node is `Ready` again using `kubectl get nodes`.

### ETCD Backup: How to take a snapshot and restore the K8s database.
The cluster stores all its state in ETCD. To interact with it securely, you must always use API version 3 and provide the server’s authentication certificates. To restore a K8s cluster, we must:
1. Obtain the connection parameters by consulting the file `/etc/kubernetes/manifests/etcd.yaml`, looking for the lines that define `--listen-client-urls`, `--cacert`, `--cert` and `--key`.
2. Take a backup snapshot:
```
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save ‘backup_path’
```
3. Verify that the snapshot has been created correctly with `ETCDCTL_API=3 etcdctl --write-out=table snapshot status ‘backup_path’`.
4. Restore the database:
```
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --data-dir=/var/lib/etcd-backup \
  snapshot restore ‘backup_path’
```
5. After restoring, you must point ETCD to the new directory we have just created by editing the `hostPath` path in the `volumes` section of the `/etc/kubernetes/manifests/etcd.yaml` file.
6. We verify that `kubelet` has detected the change, destroyed the current ETCD Pod and spun up a new one with the restored data using the command `kubectl get pods -n kube-system -w`.

### Broken Ingress: Identifying why traffic isn’t reaching the service.
1. Verificar la salud de los Pods y el Service con `kubectl get pods -l <selector-del-service>`.
2. Comprobar que el service tiene Endpoints asignados. Si la lista de ENDPOINTS está vacía, el problema no es el Ingress, sino que el selector del Service no coincide con las labels de tus Pods:
    ```
    kubectl get svc <nombre-del-service>
    kubectl get endpoints <nombre-del-service>
    ```
3. LLegados a este punto hay tres escenarios principales:
    - **Inspeccionar el objeto ingress: `kubectl describe ingress <nombre-del-ingress>`.**
    - **Verificar la ingress class: `ingressClassName: nginx`.**
    - **Revisar los logs del ingress controller:**
    ```
    kubectl get pods -A | grep ingress
    kubectl logs -n <namespace-del-ingress> <nombre-del-pod-ingress-controller> | grep -i error
    ```