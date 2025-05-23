output "mario_endpoint" {
  description = "The external IP address where the Mario game can be accessed"
  value       = data.kubernetes_service_v1.gateway_service.status[0].load_balancer[0].ingress[0].ip
}
