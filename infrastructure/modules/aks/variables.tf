variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "kubernetes_version" {
  type    = string
  default = null
}
variable "sku_tier" {
  type    = string
  default = "Paid"
}
variable "network_plugin" {
  type    = string
  default = "kubenet"
}
variable "network_plugin_mode" {
  description = "AKS network plugin mode (e.g., overlay for Azure CNI overlay)"
  type        = string
  default     = null
}
variable "pod_cidr" {
  description = "Pod CIDR when using Azure CNI overlay"
  type        = string
  default     = null
}
variable "api_server_authorized_ip_ranges" {
  type    = list(string)
  default = []
}

variable "system_node_pool" {
  description = "System node pool settings"
  type = object({
    name            = string
    vm_size         = string
    node_count      = number
    os_disk_size_gb = number
    max_pods        = number
    zones           = list(string)
  })
}

variable "user_node_pools" {
  description = "List of user node pools"
  type = list(object({
    name            = string
    vm_size         = string
    node_count      = number
    mode            = string
    os_disk_size_gb = number
    max_pods        = number
    taints          = list(string)
    labels          = map(string)
    zones           = list(string)
  }))
}
