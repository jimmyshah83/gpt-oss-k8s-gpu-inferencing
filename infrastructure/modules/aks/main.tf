resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.name}-dns"

  sku_tier = var.sku_tier

  default_node_pool {
    name                = var.system_node_pool.name
    vm_size             = var.system_node_pool.vm_size
    node_count          = var.system_node_pool.node_count
    os_disk_size_gb     = var.system_node_pool.os_disk_size_gb
    max_pods            = var.system_node_pool.max_pods
    zones               = var.system_node_pool.zones
    only_critical_addons_enabled = true
    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  api_server_access_profile {
    authorized_ip_ranges = var.api_server_authorized_ip_ranges
  }

  network_profile {
  network_plugin      = var.network_plugin
  network_plugin_mode = var.network_plugin_mode
  pod_cidr            = var.pod_cidr
  }

  kubernetes_version = var.kubernetes_version
}

resource "azurerm_kubernetes_cluster_node_pool" "user_pools" {
  for_each            = { for p in var.user_node_pools : p.name => p }
  name                = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size             = each.value.vm_size
  node_count          = each.value.node_count
  mode                = each.value.mode
  os_disk_size_gb     = each.value.os_disk_size_gb
  max_pods            = each.value.max_pods
  node_taints         = each.value.taints
  node_labels         = each.value.labels
  zones               = each.value.zones
}

output "name" { value = azurerm_kubernetes_cluster.this.name }
output "kube_admin_config" {
  value = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  sensitive = true
}
