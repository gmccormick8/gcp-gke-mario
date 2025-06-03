data "kubernetes_resource" "mario_gateway" {
  api_version = "gateway.networking.k8s.io/v1beta1"
  kind        = "Gateway"

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
  value       = try(data.kubernetes_resource.mario_gateway.object.status.addresses[0].value, null)
}
