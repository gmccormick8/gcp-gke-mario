data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "http://${var.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

resource "kubernetes_namespace" "mario" {
  metadata {
    name = "mario"
  }
}

resource "kubernetes_deployment_v1" "mario_v1" {
  metadata {
    name      = "mario"
    namespace = kubernetes_namespace.mario.metadata[0].name
    labels = {
      app = "mario"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "mario"
      }
    }

    template {
      metadata {
        labels = {
          app = "mario"
        }
      }

      spec {
        container {
          name              = "mario"
          image             = var.image
          image_pull_policy = "Always"

          resources {
            limits = {
              cpu    = "1000m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          port {
            container_port = 80
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
          }

        }
      }
    }
  }
}

resource "kubernetes_service_v1" "default" {
  metadata {
    name      = "mario-service"
    namespace = kubernetes_namespace.mario.metadata[0].name
    labels = {
      app = "mario"
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.mario_v1.metadata[0].labels["app"]
    }

    port {
      port        = 80
      target_port = kubernetes_deployment_v1.mario_v1.spec[0].template[0].spec[0].container[0].port[0].container_port
    }

    type = "LoadBalancer"
  }

}

resource "kubernetes_horizontal_pod_autoscaler_v2" "hpa" {
  metadata {
    name      = "mario-hpa"
    namespace = kubernetes_namespace.mario.metadata[0].name
  }
  spec {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    scale_target_ref {
      kind = "Deployment"
      name = kubernetes_deployment_v1.mario_v1.metadata[0].name
    }

    metric {
      type = "Resource"

      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 75
        }
      }
    }
  }

}
