output "mario_endpoint" {
  description = "The endpoint URL where the Mario game will be accessible"
  value       = "http://${module.k8s-mario-central.load_balancer_ip}"
}
