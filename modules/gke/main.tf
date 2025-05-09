# Create GKE service account
resource "google_service_account" "gke_sa" {
  project      = var.project_id
  account_id   = "${var.cluster_name}-sa"
  display_name = "GKE Service Account for ${var.cluster_name}"
}

# Add IAM role bindings for GKE service account
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer",
    "roles/artifactregistry.reader"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# Create GKE cluster
resource "google_container_cluster" "primary" {
  name                = var.cluster_name
  project             = var.project_id
  location            = var.region
  network             = var.network_id
  subnetwork          = var.subnet_id
  enable_autopilot    = true
  deletion_protection = false

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.gke_sa.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    }
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
    private_endpoint_enforcement_enabled = true
  }

  release_channel {
    channel = "STABLE"
  }

  enterprise_config {
    desired_tier = "STANDARD"
  }

}
