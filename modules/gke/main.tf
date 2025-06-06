resource "google_service_account" "gke_sa" {
  account_id   = "gke-${var.zone}-sa"
  display_name = "GKE Service Account for ${var.zone}"
}

resource "google_project_iam_member" "gke_sa_node_service_agent_role" {
  project = var.project_id
  role    = "roles/container.nodeServiceAgent"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_sa_network_viewer_role" {
  project = var.project_id
  role    = "roles/compute.networkViewer"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_sa_container_admin_role" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# Create a Standard GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone
  project  = var.project_id

  deletion_protection = false

  network    = var.network_name
  subnetwork = var.subnet_name

  remove_default_node_pool = true
  initial_node_count       = 1

  enable_intranode_visibility = true

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_network_name
    services_secondary_range_name = var.services_network_name
  }

  vertical_pod_autoscaling {
    enabled = false
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  fleet {
    project = var.project_id
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  authenticator_groups_config {
    security_group = "gke-security-groups@${var.project_id}.iam.gserviceaccount.com"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Configure master authorized networks to only allow:
  # 1. Google Compute Engine Public IPs (for Cloud Shell and Console access)
  # 2. A single whitelisted IP (for direct kubectl access)
  # This provides secure control plane access without requiring a bastion host
  master_authorized_networks_config {
    gcp_public_cidrs_access_enabled = true # Allow Google Compute Engine Public IPs
    cidr_blocks {
      cidr_block   = "${var.public_ip}/32" # Allow single whitelisted IP
      display_name = "allow-current-host"
    }
  }

  network_policy {
    enabled = true
  }

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  release_channel {
    channel = "REGULAR"
  }

  resource_labels = {
    "k8s-cluster" = var.cluster_name
    "environment" = var.environment
  }
}

# Create a node pool for the GKE cluster
resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.cluster_name}-node-pool"
  location = var.zone
  cluster  = google_container_cluster.primary.name
  project  = var.project_id

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {

    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    service_account = google_service_account.gke_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  network_config {
    enable_private_nodes = true
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  upgrade_settings {
    strategy        = "SURGE"
    max_surge       = max(ceil(var.min_node_count * 0.25), 1)
    max_unavailable = 0
  }
}
