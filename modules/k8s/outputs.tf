data "kubernetes_service_v1" "mario_lb" {
  count = var.config_cluster ? 1 : 0

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
  value       = data.kubernetes_service_v1.mario_lb[0].status[0].load_balancer[0].ingress[0].ip
}
