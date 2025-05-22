output "load_balancer_ip" {
  description = "External IP address of the gateway load balancer"
  value       = data.kubernetes_service_v1.gateway_service.status[0].load_balancer[0].ingress[0].ip
}

data "kubernetes_service_v1" "gateway_service" {
  provider = kubernetes.central
  metadata {
    name      = "mario-gateway-external"
    namespace = "mario"
  }
  depends_on = [kubernetes_manifest.gateway]
}
