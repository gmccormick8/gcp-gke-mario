variable "cluster_name" {
  description = "The name of the cluster."
  type        = string  
}

variable "cluster_location" {
  description = "The location of the cluster."
  type        = string
}

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