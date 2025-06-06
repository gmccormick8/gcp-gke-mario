variable "image" {
  description = "The Docker image to use for the deployment."
  type        = string
}

variable "min_replicas" {
  description = "Minimum number of replicas for the deployment."
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of replicas for the deployment."
  type        = number
  default     = 5
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the cluster"
  type        = string
}

variable "cluster_ca_cert" {
  description = "The CA certificate of the cluster"
  type        = string
}

variable "config_cluster" {
  description = "Set to true to enable gateway and HTTP Route configuration on this cluster"
  type        = bool
}