output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.prod_central_cluster.cluster_endpoint
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.prod_central_cluster.cluster_name
}

output "cluster_location" {
  description = "GKE cluster location"
  value       = "us-central1"
}
