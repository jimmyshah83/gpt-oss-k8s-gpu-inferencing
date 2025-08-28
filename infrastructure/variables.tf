variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "southcentralus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-gpt-oss-aks"
}

variable "aks_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-gpt-oss"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "AKS SKU tier: Free or Paid"
  type        = string
  default     = "Free"
}

variable "network_plugin" {
  description = "AKS network plugin"
  type        = string
  default     = "azure"
}

variable "network_plugin_mode" {
  description = "AKS network plugin mode (use 'overlay' for Azure CNI overlay)"
  type        = string
  default     = "overlay"
}

variable "pod_cidr" {
  description = "Pod CIDR for overlay networking"
  type        = string
  default     = "10.244.0.0/16"
}

variable "api_server_authorized_ip_ranges" {
  description = "Authorized IP ranges for the API server (empty means public open)"
  type        = list(string)
  default     = []
}

variable "zones" {
  description = "Availability zones to use for node pools (optional)"
  type        = list(string)
  default     = []
}

# System pool
variable "system_pool_name" {
  type    = string
  default = "sys"
}
variable "system_pool_vm_size" {
  type    = string
  default = "Standard_D8s_v6"
}
variable "system_pool_node_count" {
  type    = number
  default = 1
}
variable "system_pool_os_disk_size_gb" {
  type    = number
  default = 128
}
variable "system_pool_max_pods" {
  type    = number
  default = 110
}

# CPU user pool
variable "cpu_user_pool_name" {
  type    = string
  default = "cpu"
}
variable "cpu_user_pool_vm_size" {
  type    = string
  default = "Standard_D16s_v6"
}
variable "cpu_user_pool_node_count" {
  type    = number
  default = 2
}
variable "cpu_user_pool_os_disk_size_gb" {
  type    = number
  default = 128
}
variable "cpu_user_pool_max_pods" {
  type    = number
  default = 110
}
variable "cpu_user_pool_labels" {
  type        = map(string)
  default     = { "workload" = "cpu" }
}

# GPU user pool
variable "gpu_pool_name" {
  type    = string
  default = "gpu"
}
variable "gpu_pool_vm_size" {
  type    = string
  default = "Standard_NC80adis_H100_v5"
}
variable "gpu_pool_node_count" {
  type    = number
  default = 1
}
variable "gpu_pool_os_disk_size_gb" {
  type    = number
  default = 300
}
variable "gpu_pool_max_pods" {
  type    = number
  default = 60
}
variable "gpu_pool_labels" {
  type        = map(string)
  default     = { "workload" = "gpu", "gpu" = "h100" }
}
