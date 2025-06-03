data "kubernetes_resource" "mario_gateway" {
  api_version = "gateway.networking.k8s.io/v1beta1"
  kind        = "Gateway"

  metadata {
    name      = "mario-external-gateway"
    namespace = "mario"
  }

  provider = kubernetes.central

  depends_on = [
    module.k8s-mario-central
  ]
}

output "mario_endpoint" {
  description = "You can access the Mario game at this URL"
  value = try("http://${data.kubernetes_resource.mario_gateway.object.status.addresses[0].value}")
}
