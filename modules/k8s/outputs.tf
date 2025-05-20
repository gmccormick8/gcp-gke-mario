output "load_balancer_ip" {
  description = "External IP address of the load balancer"
  value       = data.kubernetes_service_v1.mario_service.status[0].load_balancer[0].ingress[0].ip
}

data "kubernetes_service_v1" "mario_service" {
  metadata {
    name      = "mario-service"
    namespace = helm_release.mario.namespace
  }
  depends_on = [helm_release.mario]
}
