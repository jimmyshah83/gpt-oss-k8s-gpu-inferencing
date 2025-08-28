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

## 3) Deploy a minimal RayCluster (CPU)

Save as `raycluster-minimal.yaml` and apply it.

```yaml
apiVersion: ray.io/v1
kind: RayCluster
metadata:
	name: raycluster-minimal
spec:
	headGroupSpec:
		serviceType: ClusterIP
		template:
			spec:
				containers:
					- name: ray-head
						image: rayproject/ray:2.31.0-py310
						resources:
							requests:
								cpu: "1"
								memory: "2Gi"
						ports:
							- containerPort: 6379
								name: gcs
							- containerPort: 8265
								name: dashboard
							- containerPort: 10001
								name: client
						command: ["ray", "start", "--head", "--dashboard-host=0.0.0.0"]
	workerGroupSpecs:
		- groupName: small-group
			replicas: 1
			template:
				spec:
					containers:
						- name: ray-worker
							image: rayproject/ray:2.31.0-py310
							resources:
								requests:
									cpu: "1"
									memory: "2Gi"
							command: ["ray", "start", "--address=$(RAY_HEAD_SERVICE_HOST):6379"]
```

Apply and check status:

```bash
kubectl apply -f raycluster-minimal.yaml
kubectl get rayclusters
kubectl get pods -l ray.io/cluster=raycluster-minimal

# Optional: port-forward the Ray Dashboard
kubectl port-forward svc/raycluster-minimal-head-svc 8265:8265
# Then open http://localhost:8265
```

## 4) (Optional) Deploy a GPU-enabled RayCluster

Make sure the NVIDIA device plugin is running on your GPU nodes. Then use a worker group that requests GPUs. Adjust selectors/tolerations to match your cluster labels if needed.

```yaml
apiVersion: ray.io/v1
kind: RayCluster
metadata:
	name: raycluster-gpu
spec:
	headGroupSpec:
		serviceType: ClusterIP
		template:
			spec:
				containers:
					- name: ray-head
						image: rayproject/ray:2.31.0-py310
						resources:
							requests:
								cpu: "1"
								memory: "2Gi"
						command: ["ray", "start", "--head", "--dashboard-host=0.0.0.0"]
	workerGroupSpecs:
		- groupName: gpu-group
			replicas: 1
			template:
				spec:
					# Example: select GPU nodes (update to your cluster's labels if different)
					# nodeSelector:
					#   nvidia.com/gpu.present: "true"
					containers:
						- name: ray-worker
							image: rayproject/ray:2.31.0-py310
							resources:
								limits:
									nvidia.com/gpu: 1
								requests:
									cpu: "2"
									memory: "8Gi"
							env:
								- name: NVIDIA_VISIBLE_DEVICES
									value: "all"
							command: ["ray", "start", "--address=$(RAY_HEAD_SERVICE_HOST):6379"]
```

Apply and verify:

```bash
kubectl apply -f raycluster-gpu.yaml
kubectl get pods -l ray.io/cluster=raycluster-gpu
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

