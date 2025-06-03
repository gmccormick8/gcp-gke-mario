output "mario_endpoint" {
  description = "You can access the Mario game at this URL"
  value = try(
    module.k8s-mario-central.load_balancer_ip != null ? "http://${module.k8s-mario-central.load_balancer_ip}" : "Waiting for load balancer IP... (this can take up to 5 minutes)",
    "Waiting for load balancer IP... (this can take up to 5 minutes)"
  )
}
