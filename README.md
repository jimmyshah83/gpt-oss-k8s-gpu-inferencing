# gpt-oss-k8s-gpu-inferencing

## Things to be completed

1. Public AKS cluster in US South Central 
2. 2 Node pools, CPU x 2 System node pools on 3 year savings plan (D16s v5) 
3. GPU H100 x 2 (Standard_NC80adis_H100_v5) user node pool
4. Enable GPU nodes with NVIDIA GPU drivers
5. Deploy a Ray Cluster on CPU node pool using Kuberay
6. Deployment
    1. Ray Service custom resource for gpt-oss-120b OR
    2. Manual deployment using python