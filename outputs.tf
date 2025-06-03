output "mario_endpoint" {
  description = "You can access the Mario game at this URL"
  value       = "http://${module.k8s-mario-central.load_balancer_ip}"
}