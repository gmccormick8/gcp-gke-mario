output "cluster_id" {
  description = "The full ID of the GKE cluster"
  value       = google_container_cluster.primary.id
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_location" {
  description = "The location of the cluster"
  value       = google_container_cluster.primary.location
}

output "master_auth" {
  description = "The authentication information for accessing the Kubernetes master"
  value = {
    cluster_ca_certificate = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  }
  sensitive = true
}

output "cluster_endpoint" {
  description = "The IP address of the cluster master"
  value       = google_container_cluster.primary.endpoint
}

output "fleet_membership_id" {
  description = "The ID of the fleet membership"
  value       = var.cluster_name
}

output "gke_hub_membership_id" {
  description = "The full resource ID of the cluster's fleet membership"
  value       = google_gke_hub_membership.cluster_membership.id
}
