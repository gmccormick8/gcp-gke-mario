data "google_compute_network" "network" {
  name    = var.network_name
  project = var.project_id
}

data "google_compute_subnetwork" "subnet" {
  name    = var.subnet_name
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # Enable Autopilot
  enable_autopilot = true

  # Network configuration
  network    = data.google_compute_network.network.self_link
  subnetwork = data.google_compute_subnetwork.subnet.self_link

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # IP allocation policy
  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.subnet_name}-pods"
    services_secondary_range_name = "${var.subnet_name}-services"
  }

  # Release channel
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

  # Workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Network policy
  network_policy {
    enabled  = true
    provider = "PROVIDER_UNSPECIFIED" # Autopilot manages this
  }

  # Binary authorization
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }
}
