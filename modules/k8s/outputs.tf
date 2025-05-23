output "load_balancer_ip" {
  description = "External IP address of the gateway load balancer"
  value       = data.kubernetes_service_v1.gateway_service.status[0].load_balancer[0].ingress[0].ip
}