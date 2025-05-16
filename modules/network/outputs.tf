output "network" {
  description = "The created network"
  value       = google_compute_network.vpc
}

output "network_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "network_self_link" {
  description = "The URI of the VPC"
  value       = google_compute_network.vpc.self_link
}

output "subnets" {
  description = "Map of subnet details"
  value       = google_compute_subnetwork.subnets
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.id }
}

output "secondary_ranges" {
  description = "Map of secondary ranges"
  value = { for k, v in google_compute_subnetwork.subnets : k =>
    {
      name  = k
      range = v.secondary_ip_range
    }
  }
}