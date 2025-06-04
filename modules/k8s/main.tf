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

# Check for ServiceExport CRD
resource "kubernetes_manifest" "check_service_export_crd" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind       = "CustomResourceDefinition"
    metadata = {
      name = "serviceexports.net.gke.io"
    }
  }

  timeouts {
    create = "5m"
  }
}

# Fallback wait if CRD check fails
resource "null_resource" "wait_for_crds" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "sleep 180"
  }
}

# Deploy Mario to cluster
resource "helm_release" "mario" {
  depends_on = [kubernetes_manifest.check_service_export_crd, null_resource.wait_for_crds]

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
