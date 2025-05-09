variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_name" {
  description = "The name of the network"
  type        = string
}

variable "routing_mode" {
  description = "The network routing mode (default 'GLOBAL')"
  type        = string
  default     = "GLOBAL"
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    region = string
    cidr   = string
  }))
}

variable "firewall_rules" {
  description = "Map of firewall rules"
  type = map(object({
    direction     = string
    priority      = optional(number)
    source_ranges = optional(list(string))
    target_tags   = optional(list(string))
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
  }))
  default = {}
}

variable "cloud_nat_configs" {
  description = "Map of regions where Cloud NAT should be configured"
  type        = set(string)
  default     = []
}
