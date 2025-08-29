# Deploy KubeRay Operator on Kubernetes

This guide installs the KubeRay Operator via Helm, verifies the CRDs, and shows how to deploy a minimal RayCluster (CPU) and an optional GPU-enabled RayCluster.

## Prerequisites

- A running Kubernetes cluster with kubectl access
- Helm 3 installed
- Optional for GPUs: NVIDIA drivers on nodes and the NVIDIA device plugin. This repo includes a DaemonSet you can apply:

```bash
kubectl apply -f ../setup/nvidia-device-plugin-ds.yaml
```

## 1) Install the KubeRay Operator

```bash
# Add the KubeRay Helm repo
helm repo add kuberay https://ray-project.github.io/kuberay-helm/
helm repo update

# Create a namespace for the operator
kubectl create namespace ray-system --dry-run=client -o yaml | kubectl apply -f -

# Install the operator
helm install kuberay-operator kuberay/kuberay-operator -n ray-system -f k8s/kuberay-operator-values.yaml
```

## 2) Verify installation

```bash
# Operator pod should be Running
kubectl get pods -n ray-system

# CRDs should exist
kubectl get crd | grep -i ray
```

## 3) Deploy a gpt-oss model

`kubectl apply -f <Rayserve Deployment>`

## 4) Monitor

- Ray Cluster
* Deploying ray serve should deploy a cluster and service for me
```
kubectl api-resources --api-group=ray.io
kubectl get rayclusters.ray.io -A
kubectl get rayservices.ray.io -A
kubectl get rayjobs.ray.io -A

# View the pods in the RayCluster named "raycluster-kuberay"
kubectl get pods --selector=ray.io/cluster=raycluster-kuberay
```

-  Verify the Kubernetes cluster status after deploying ray service
```
# Step 4.1: List all RayService custom resources in the `default` namespace.
kubectl get rayservice

# [Example output]
# NAME                SERVICE STATUS   NUM SERVE ENDPOINTS
# rayservice-sample   Running          2

# Step 4.2: List all RayCluster custom resources in the `default` namespace.
kubectl get raycluster

# [Example output]
# NAME                      DESIRED WORKERS   AVAILABLE WORKERS   CPUS    MEMORY   GPUS   STATUS   AGE
# rayservice-sample-cxm7t   1                 1                   2500m   4Gi      0      ready    79s

# Step 4.3: List all Ray Pods in the `default` namespace.
kubectl get pods -l=ray.io/is-ray-node=yes

# [Example output]
# NAME                                               READY   STATUS    RESTARTS   AGE
# rayservice-sample-cxm7t-head                       1/1     Running   0          3m5s
# rayservice-sample-cxm7t-small-group-worker-8hrgg   1/1     Running   0          3m5s

# Step 4.4: Check the `Ready` condition of the RayService.
# The RayService is ready to serve requests when the condition is `True`.
kubectl describe rayservices.ray.io rayservice-sample

# [Example output]
# Conditions:
#   Last Transition Time:  2025-06-26T13:23:06Z
#   Message:               Number of serve endpoints is greater than 0
#   Observed Generation:   1
#   Reason:                NonZeroServeEndpoints
#   Status:                True
#   Type:                  Ready

# Step 4.5: List services in the `default` namespace.
kubectl get services

# NAME                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                         AGE
# ...
# rayservice-sample-cxm7t-head-svc   ClusterIP   None            <none>        10001/TCP,8265/TCP,6379/TCP,8080/TCP,8000/TCP   71m
# rayservice-sample-head-svc         ClusterIP   None            <none>        10001/TCP,8265/TCP,6379/TCP,8080/TCP,8000/TCP   70m
# rayservice-sample-serve-svc        ClusterIP   10.96.125.107   <none>        8000/TCP                                        70m
```

## 5) Uninstall

```bash
# Delete RayClusters (if any)
kubectl delete raycluster --all

# Remove the operator
helm uninstall kuberay-operator -n ray-system
kubectl delete namespace ray-system

# (Optional) Remove CRDs if you won't use KubeRay anymore
kubectl get crd | grep -i ray | awk '{print $1}' | xargs -I{} kubectl delete crd {}
```

References:
- KubeRay Helm charts: https://github.com/ray-project/kuberay-helm
- KubeRay docs: https://docs.ray.io/en/latest/cluster/kubernetes/kuberay/getting-started.html
