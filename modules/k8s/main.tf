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

resource "kubernetes_service_account" "mario_sa" {
  metadata {
    name      = "mario-sa"
    namespace = helm_release.mario.namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.mario_gsa.email
    }
  }
}

resource "google_service_account" "mario_gsa" {
  account_id   = "mario-gsa"
  display_name = "Mario Google Service Account"
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.mario_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_service_account.mario_sa.metadata[0].namespace}/${kubernetes_service_account.mario_sa.metadata[0].name}]"
  ]
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

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.mario_sa.metadata[0].name
  }

  depends_on = []
}
