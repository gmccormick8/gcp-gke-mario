variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "Region where the cluster will be created"
  type        = string
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "authorized_networks" {
  description = "List of authorized networks that can access the cluster"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}
