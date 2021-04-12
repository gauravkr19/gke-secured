variable "project_id" {
  type = string
}
variable "region" {
  type = string
}

variable "regional" {
  type = bool
  default = false
}

variable "zones" {
  type = list(string)
  default = ["us-central1-a"]
}

variable "gke_num_nodes" {
  type = number
  default = 1
}

variable "ip_cidr_subnet_nodes" {
  default = "10.0.0.0/16"
  description = "Nodes CIDR"
}

variable "ip_cidr_subnet_pods" {
  default = "10.3.0.0/16"
  description = "Pod CIDR"
}

variable "ip_cidr_subnet_nodes_services" {  
  default = "10.2.0.0/16"
  description = "Services CIDR"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region."
  default     = "latest"
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)."
  default     = []
}

variable "enable_shielded_nodes" {
  default = true
}

variable "pod_security_policy_enabled" {
  default = false
}
variable "enable_binary_authorization" {
  default = false
}

variable "network_policy" {
  type        = bool
  description = "disabled=false to enable netpol; also nodepool netpol should be enabled for it to work"
  default     = false 
}

variable "http_load_balancing" {
  type        = bool
  description = "disabled=false to enable netpol; also nodepool netpol should be enabled for it to work"
  default     = false  
}

variable "horizontal_pod_autoscaling" {
  type        = bool
  description = "disabled=false to enable netpol; also nodepool netpol should be enabled for it to work"
  default     = false 
}