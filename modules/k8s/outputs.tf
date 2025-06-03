data "kubernetes_service_v1" "mario_lb" {

  metadata {
    name      = "mario-external-gateway"
    namespace = "mario"
  }

  depends_on = [
    helm_release.mario
  ]
}

output "load_balancer_ip" {
  description = "The IP address of the global load balancer"
  value       = data.kubernetes_service_v1.mario_lb.status.load_balancer.ingress.ip
}
