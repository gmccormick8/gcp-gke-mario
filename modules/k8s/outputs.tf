output "load_balancer_ip" {
  description = "The IP address of the load balancer (only available when gateway is enabled)"
  value       = var.extra_values.gateway.enabled ? data.kubernetes_service.gateway_ip[0].status[0].load_balancer[0].ingress[0].ip : null
}

data "kubernetes_service" "gateway_ip" {
  count = var.extra_values.gateway.enabled ? 1 : 0
  metadata {
    name      = "external-http"
    namespace = helm_release.mario.namespace
  }
  depends_on = [helm_release.mario]
}
