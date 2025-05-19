resource "google_service_account" "gke_sa" {
  account_id   = "gke-${var.region}-sa"
  display_name = "GKE Service Account for ${var.region}"
}

resource "google_project_iam_member" "gke_sa_log_write_role" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_sa_metric_write_role" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  enable_autopilot = true

  deletion_protection = false

  network    = var.network_name
  subnetwork = var.subnet_name

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }


  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_network_name
    services_secondary_range_name = var.services_network_name
  }

  release_channel {
    channel = "REGULAR"
  }

  master_authorized_networks_config {
    gcp_public_cidrs_access_enabled = true
    cidr_blocks {
      cidr_block   = "${var.public_ip}/32"
      display_name = "allow-current-host"
    }
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.gke_sa.email
      oauth_scopes = [
        "https://www.googleapis.com/auth/monitoring.write",
        "https://www.googleapis.com/auth/logging.write"
      ]
    }
  }

  vertical_pod_autoscaling {
    enabled = false
  }
}
