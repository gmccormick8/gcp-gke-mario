# Wait for metrics API and cluster auth
resource "time_sleep" "wait_for_cluster_auth" {
  create_duration = "360s" # Increased wait time

  triggers = {
    cluster_endpoint = var.cluster_endpoint
    cluster_ca_cert  = var.cluster_ca_cert
    metrics_check    = "metrics.k8s.io/v1beta1" # Add metrics API to triggers
  }
}

# Verify metrics API availability
resource "null_resource" "verify_metrics_api" {
  provisioner "local-exec" {
    command = <<-EOT
      until kubectl api-resources --api-group=metrics.k8s.io/v1beta1 &>/dev/null; do
        echo "Waiting for metrics API..."
        sleep 10
      done
    EOT
  }

  depends_on = [time_sleep.wait_for_cluster_auth]
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

  depends_on = [time_sleep.wait_for_cluster_auth, null_resource.verify_metrics_api]
}
