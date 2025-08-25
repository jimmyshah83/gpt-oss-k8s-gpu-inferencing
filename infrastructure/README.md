# Infrastructure (Terraform)

This folder provisions a minimal, public AKS cluster with three node pools in `southcentralus` using Terraform. It intentionally creates only the resources required for AKS:

- Resource Group
- AKS Cluster (system-assigned identity)
- One system node pool (1 x Standard_D8s_v5)
- One CPU user node pool (2 x Standard_D16s_v5)
- One GPU user node pool (2 x Standard_NC80adis_H100_v5)

Notes:

- API server is public. Restrict with `api_server_authorized_ip_ranges` if needed.
- Networking uses `kubenet` to avoid additional infra.
- NVIDIA GPU driver support should be enabled post-deploy using the AKS GPU Operator or `nvidia-device-plugin` DaemonSet.
- Azure Savings Plans are configured at the billing/subscription scope and cannot be attached to a specific node pool in Terraform. Ensure your subscription has an active 3-year savings plan to cover the CPU user pool usage.

## How to use

1. Ensure you are logged into Azure and have the desired subscription selected.
1. Export the subscription ID for Terraform:

```sh
export TF_VAR_subscription_id="$(az account show --query id -o tsv)"
```

1. From this folder, initialize and apply:

```sh
terraform init
terraform plan -out tf.plan
terraform apply tf.plan
```

### Customization

- Change names and counts via `variables.tf` or with `-var` CLI args.
- To lock down the API server, set `api_server_authorized_ip_ranges` to a list of CIDRs.
- To change regions, override `location`.

### GPU Enablement

After the cluster is ready, deploy the GPU operator (example):

- Install NVIDIA GPU Operator via Helm to enable drivers and runtime for H100 nodes. Refer to AKS docs for the latest steps.
