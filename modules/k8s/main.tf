data "google_client_config" "default" {}

# Create a provider configuration for each cluster
locals {
  providers = {
    for k, v in var.clusters : k => {
      host                   = "https://${v.endpoint}"
      token                  = data.google_client_config.default.access_token
      cluster_ca_certificate = base64decode(v.ca_cert)
    }
  }
}

provider "kubernetes" {
  alias                  = "east"
  host                   = local.providers["east"].host
  token                  = local.providers["east"].token
  cluster_ca_certificate = local.providers["east"].cluster_ca_certificate
}

provider "kubernetes" {
  alias                  = "central"
  host                   = local.providers["central"].host
  token                  = local.providers["central"].token
  cluster_ca_certificate = local.providers["central"].cluster_ca_certificate
}

provider "kubernetes" {
  alias                  = "west"
  host                   = local.providers["west"].host
  token                  = local.providers["west"].token
  cluster_ca_certificate = local.providers["west"].cluster_ca_certificate
}

provider "helm" {
  alias = "east"
  kubernetes {
    host                   = local.providers["east"].host
    token                  = local.providers["east"].token
    cluster_ca_certificate = local.providers["east"].cluster_ca_certificate
  }
}

provider "helm" {
  alias = "central"
  kubernetes {
    host                   = local.providers["central"].host
    token                  = local.providers["central"].token
    cluster_ca_certificate = local.providers["central"].cluster_ca_certificate
  }
}

provider "helm" {
  alias = "west"
  kubernetes {
    host                   = local.providers["west"].host
    token                  = local.providers["west"].token
    cluster_ca_certificate = local.providers["west"].cluster_ca_certificate
  }
}

# Wait for cluster resources to be ready
resource "time_sleep" "wait_for_clusters" {
  depends_on = [
    helm_release.mario_east,
    helm_release.mario_central,
    helm_release.mario_west
  ]

  create_duration = "10m"
}

# Deploy Gateway API resources
resource "kubernetes_manifest" "gateway_class" {
  provider = kubernetes.central
  depends_on = [
    helm_release.mario_east,
    helm_release.mario_central,
    helm_release.mario_west
  ]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1beta1"
    kind       = "GatewayClass"
    metadata = {
      name = "gke-l7-global-mc-gatewayclass"
      annotations = {
        "networking.gke.io/default-gateway-class" = "true"
      }
    }
    spec = {
      controllerName = "gke.io/gateway-controller"
    }
  }
}

resource "kubernetes_manifest" "gateway" {
  provider   = kubernetes.central
  depends_on = [kubernetes_manifest.gateway_class]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1beta1"
    kind       = "Gateway"
    metadata = {
      name      = "mario-gateway"
      namespace = "mario"
      annotations = {
        "networking.gke.io/certmap"             = ""
        "networking.gke.io/force-http-to-https" = "false"
      }
    }
    spec = {
      gatewayClassName = "gke-l7-global-mc-gatewayclass"
      listeners = [{
        name     = "http"
        protocol = "HTTP"
        port     = 80
        allowedRoutes = {
          kinds = [{
            kind = "HTTPRoute"
          }]
          namespaces = {
            from = "Same"
          }
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "http_route" {
  provider   = kubernetes.central
  depends_on = [kubernetes_manifest.gateway]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1beta1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "mario-route"
      namespace = "mario"
      labels = {
        "gateway" = "mario-gateway"
      }
    }
    spec = {
      parentRefs = [{
        name      = "mario-gateway"
        namespace = "mario"
      }]
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }
        }]
        backendRefs = [
          for cluster in var.clusters : {
            name      = "mario-service"
            namespace = "mario"
            port      = 80
            weight    = 1
          }
        ]
      }]
    }
  }
}

# Deploy Mario to each cluster
resource "helm_release" "mario_east" {
  provider = helm.east

  name             = "mario"
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
    })
  ]
}

resource "helm_release" "mario_central" {
  provider = helm.central

  name             = "mario"
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
    })
  ]
}

resource "helm_release" "mario_west" {
  provider = helm.west

  name             = "mario"
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
    })
  ]
}
