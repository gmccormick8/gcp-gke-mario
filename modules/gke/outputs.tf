output "cluster_id" {
  description = "The ID of the GKE cluster"
  value       = google_container_cluster.primary.id
}

output "service_account_id" {
  description = "The ID of the GKE service account"
  value       = google_service_account.gke_sa.id
}
