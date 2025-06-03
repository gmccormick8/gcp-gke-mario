output "mario_endpoint" {
  description = "You can access the Mario game at this URL"
  value       = try(coalesce("http://${module.k8s-mario-central.load_balancer_ip}", "Waiting for load balancer IP... Please try again in a few minutes."), "Waiting for load balancer IP... Please try again in a few minutes.")
}
