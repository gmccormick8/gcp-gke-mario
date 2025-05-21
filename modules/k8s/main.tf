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

  # Override the default values.yaml values.
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
    })
  ]

  lifecycle {
    precondition {
      condition     = can(regex(":", var.image))
      error_message = "The image variable must include a tag (format: repository:tag)"
    }
    prevent_destroy = false
  }
}
