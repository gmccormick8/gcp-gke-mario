variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
  default     = "mario-cluster"
}

variable "cluster_location" {
  description = "The location of the cluster."
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
  default     = "us-central1"
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
  default     = "172.16.0.0/28"
}

variable "n" {

}

variable "pods_cidr" {
  description = "The CIDR block for the pods IP range."
  type        = string
}

variable "services_cidr" {
  description = "The CIDR block for the services IP range."
  type        = string
}
