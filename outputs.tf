data "kubernetes_resource" "mario_gateway" {
  provider = kubernetes.central

  api_version = "gateway.networking.k8s.io/v1beta1"
  kind        = "Gateway"

  metadata {
    name      = "mario-external-gateway"
    namespace = "mario"
  }

  depends_on = [
    module.k8s-mario-central
  ]
}

output "mario_gateway_url" {
  description = "The external load balancer IP address for the Mario game"
  value = try(
    "You can access the Mario game at: http://${data.kubernetes_resource.mario_gateway.object.status.addresses[0].value}",
    "Waiting for load balancer IP... (this can take up to 5 minutes)"
  )
}
