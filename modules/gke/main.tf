data "google_compute_network" "network" {
  name    = var.network_name
  project = var.project_id
}

data "google_compute_subnetwork" "subnet" {
  name    = var.subnet_name
  project = var.project_id
  region  = var.region
}

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

  network    = data.google_compute_network.network.self_link
  subnetwork = data.google_compute_subnetwork.subnet.self_link

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  
  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.pods_cidr}"
    services_secondary_range_name = "${var.services_cidr}"
  }

  release_channel {
    channel = "REGULAR"
  }

  # Master authorized networks - allow all for public access
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
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
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/logging.write",
      ]
    }
  }
}
