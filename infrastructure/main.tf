provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Minimal prerequisite: Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# AKS Cluster
module "aks" {
  source              = "./modules/aks"
  name                = var.aks_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier
  network_plugin      = var.network_plugin
  network_plugin_mode = var.network_plugin_mode
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

  # System node pool (required by AKS)
  system_node_pool = {
    name                = var.system_pool_name
    vm_size             = var.system_pool_vm_size
    node_count          = var.system_pool_node_count
    os_disk_size_gb     = var.system_pool_os_disk_size_gb
    max_pods            = var.system_pool_max_pods
    zones               = var.zones
    pod_cidr            = var.pod_cidr
  }

  # Additional user node pools
  user_node_pools = [
    {
      name            = var.cpu_user_pool_name
      vm_size         = var.cpu_user_pool_vm_size
      node_count      = var.cpu_user_pool_node_count
      mode            = "User"
      os_disk_size_gb = var.cpu_user_pool_os_disk_size_gb
      max_pods        = var.cpu_user_pool_max_pods
      taints          = ["workload=ray:NoSchedule"]
      labels          = var.cpu_user_pool_labels
      zones           = var.zones
    },
    {
      name            = var.gpu_pool_name
      vm_size         = var.gpu_pool_vm_size
      node_count      = var.gpu_pool_node_count
      mode            = "User"
      os_disk_size_gb = var.gpu_pool_os_disk_size_gb
      max_pods        = var.gpu_pool_max_pods
      taints          = ["sku=gpu:NoSchedule"]
      labels          = var.gpu_pool_labels
      zones           = var.zones
    }
  ]
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "aks_name" {
  value = module.aks.name
}

output "kube_admin_config" {
  description = "Admin kubeconfig for the AKS cluster"
  value = module.aks.kube_admin_config
  sensitive = true
}
