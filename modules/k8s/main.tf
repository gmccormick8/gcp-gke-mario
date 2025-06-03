data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${var.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_cert)
}

provider "helm" {
  kubernetes {
    host                   = "https://${var.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(var.cluster_ca_cert)
  }
}

# Wait for Multi-cluster Service Discovery CRDs to be available
resource "null_resource" "wait_for_crds" {
  provisioner "local-exec" {
    command = <<EOT
      # Wait for Multi-cluster Services Feature to be enabled
      until gcloud container fleet multi-cluster-services describe \
        --project="${var.project_id}" > /dev/null 2>&1; do
        echo "Waiting for Multi-cluster Services Feature to be enabled..."
        sleep 30
      done
    EOT
  }
}

# Deploy Mario to cluster
resource "helm_release" "mario" {
  depends_on = [null_resource.wait_for_crds]

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
}
