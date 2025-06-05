# Wait for cluster auth
resource "time_sleep" "wait_for_cluster_auth" {
  create_duration = "120s"

  triggers = {
    cluster_endpoint = var.cluster_endpoint
    cluster_ca_cert  = var.cluster_ca_cert
  }
}

# Deploy Mario to cluster
resource "helm_release" "mario" {
  name             = "mario-${var.cluster_name}"
  chart            = "${path.module}/helm/mario"
  namespace        = "mario"
  create_namespace = true

  values = [
    yamlencode({
      image = {
        repository = split(":", var.image)[0]
        tag        = split(":", var.image)[1]
      }
      autoscaling = {
        minReplicas = var.min_replicas
        maxReplicas = var.max_replicas
      }
      gateway = {
        enable = var.config_cluster
      }
    })
  ]

  depends_on = [time_sleep.wait_for_cluster_auth]
}
