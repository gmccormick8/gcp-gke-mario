variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
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