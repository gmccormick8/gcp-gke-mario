output "helm_status" {
  description = "Status of the Helm release"
  value       = helm_release.mario.status
}
