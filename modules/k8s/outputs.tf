output "load_balancer_ip" {
  description = "External IP address of the load balancer"
  value       = kubernetes_service_v1.default.status.0.load_balancer.0.ingress.0.ip
}
