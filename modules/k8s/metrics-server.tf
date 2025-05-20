resource "kubernetes_namespace" "metrics_server" {
  metadata {
    name = "metrics-server"
  }
}

resource "kubernetes_deployment_v1" "metrics_server" {
  metadata {
    name      = "metrics-server"
    namespace = kubernetes_namespace.metrics_server.metadata[0].name
    labels = {
      app = "metrics-server"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "metrics-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "metrics-server"
        }
      }

      spec {
        container {
          name  = "metrics-server"
          image = "registry.k8s.io/metrics-server/metrics-server:v0.6.4"
          args = [
            "--cert-dir=/tmp",
            "--secure-port=4443",
            "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
            "--kubelet-use-node-status-port",
            "--metric-resolution=15s",
            "--kubelet-insecure-tls"
          ]

          resources {
            limits = {
              cpu    = "100m"
              memory = "200Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "100Mi"
            }
          }

          port {
            name           = "https"
            container_port = 4443
            protocol       = "TCP"
          }

          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "tmp-dir"
          empty_dir {}
        }

        service_account_name            = kubernetes_service_account_v1.metrics_server.metadata[0].name
        automount_service_account_token = true
      }
    }
  }
}

resource "kubernetes_service_v1" "metrics_server" {
  metadata {
    name      = "metrics-server"
    namespace = kubernetes_namespace.metrics_server.metadata[0].name
    labels = {
      app = "metrics-server"
    }
  }

  spec {
    port {
      name        = "https"
      port        = 443
      protocol    = "TCP"
      target_port = "https"
    }

    selector = {
      app = "metrics-server"
    }
  }
}

resource "kubernetes_service_account_v1" "metrics_server" {
  metadata {
    name      = "metrics-server"
    namespace = kubernetes_namespace.metrics_server.metadata[0].name
    labels = {
      app = "metrics-server"
    }
  }
}

resource "kubernetes_cluster_role_v1" "metrics_server" {
  metadata {
    name = "system:metrics-server"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/metrics"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "metrics_server" {
  metadata {
    name = "system:metrics-server"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.metrics_server.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.metrics_server.metadata[0].name
    namespace = kubernetes_namespace.metrics_server.metadata[0].name
  }
}

resource "kubernetes_api_service_v1" "metrics_server" {
  metadata {
    name = "v1beta1.metrics.k8s.io"
  }

  spec {
    service {
      name      = kubernetes_service_v1.metrics_server.metadata[0].name
      namespace = kubernetes_namespace.metrics_server.metadata[0].name
    }
    group                    = "metrics.k8s.io"
    version                  = "v1beta1"
    insecure_skip_tls_verify = true
    group_priority_minimum   = 100
    version_priority         = 100
  }
}
