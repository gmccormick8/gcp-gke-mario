output "cluster_id" {
  description = "The full ID of the GKE cluster"
  value       = google_container_cluster.primary.id
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_region" {
  description = "The region of the cluster"
  value       = google_container_cluster.primary.region
}

output "master_auth" {
  description = "The authentication information for accessing the Kubernetes master"
  value = {
    cluster_ca_certificate = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  }
  sensitive = true
}
