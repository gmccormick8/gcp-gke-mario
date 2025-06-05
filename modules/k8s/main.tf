data "google_client_config" "default" {}

# Increase wait time and add MCS API readiness check
resource "time_sleep" "wait_for_cluster_auth" {
  create_duration = "300s"

  triggers = {
    cluster_endpoint = var.cluster_endpoint
    cluster_ca_cert  = var.cluster_ca_cert
    mcs_check        = google_gke_hub_feature.mcs.id # Reference MCS feature to ensure it's ready
  }
}

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

# Deploy Mario to cluster
resource "helm_release" "mario" {
  name             = "mario-${var.cluster_name}"
  chart            = "./helm/mario"
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
