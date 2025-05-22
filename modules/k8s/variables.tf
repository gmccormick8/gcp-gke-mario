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

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "clusters" {
  description = "Map of cluster configurations"
  type = map(object({
    name     = string
    location = string
    endpoint = string
    ca_cert  = string
  }))
}
