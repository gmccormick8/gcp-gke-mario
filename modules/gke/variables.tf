variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "zone" {
  description = "The zone to host the cluster in"
  type        = string
}

variable "network_name" {
  description = "The VPC network to host the cluster in"
  type        = string
}

variable "subnet_name" {
  description = "The subnetwork to host the cluster in"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation for the cluster control plane"
  type        = string
}

variable "pods_network_name" {
  description = "The name of the secondary range for pods"
  type        = string
}

variable "services_network_name" {
  description = "The name of the secondary range for services"
  type        = string
}

variable "public_ip" {
  description = "This host's current Public IP, will be added to the master authorized networks"
  type        = string
}

variable "min_node_count" {
  description = "Minimum number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the node pool"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for the nodes"
  type        = string
  default     = "e2-small"
}

variable "disk_size_gb" {
  description = "Size of the node's disk in GB"
  type        = number
  default     = 25
}

variable "disk_type" {
  description = "Type of the node's disk"
  type        = string
  default     = "pd-standard"
}

variable "environment" {
  description = "Environment label for the cluster (e.g., production, staging, development)"
  type        = string
  default     = "development"
}
