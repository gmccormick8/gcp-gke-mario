data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${var.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${var.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

resource "helm_release" "mario" {
  name             = "mario"
  chart            = "${path.module}/helm/mario"
  namespace        = "mario"
  create_namespace = true
  set {
    name  = "image.repository"
    value = split(":", var.image)[0]
  }

  set {
    name  = "image.tag"
    value = split(":", var.image)[1]
  }

  values = [
    yamlencode({
      autoscaling = {
        minReplicas = var.min_replicas
        maxReplicas = var.max_replicas
      }
    })
  ]
}
