output "mario_endpoint" {
  description = "The external IP address where the Mario game can be accessed"
  value       = "http://${module.k8s-mario.load_balancer_ip}"
}
