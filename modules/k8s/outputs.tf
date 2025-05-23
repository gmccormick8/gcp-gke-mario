output "load_balancer_ip" {
  description = "The IP address of the load balancer"
  value       = data.kubernetes_service.gateway_ip[0].status[0].load_balancer[0].ingress[0].ip
}
