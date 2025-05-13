# Create a VPC network and subnet
module "prod-vpc" {
  source       = "./modules/network"
  project_id   = var.project_id
  network_name = "prod"

  subnets = {
    "prod-central-vpc" = {
      region = "us-central1"
      cidr   = "10.0.0.0/24"
      secondary_ranges = {
        "prod-central-pods" = {
          ip_cidr_range = "192.168.0.0/24"
        }
        "prod-central-services" = {
          ip_cidr_range = "192.168.10.0/24"
        }
      }
    }
  }

  firewall_rules = {
    "allow-inbound-iap-ssh-access" = {
      direction     = "INGRESS"
      source_ranges = ["35.235.240.0/20"]
      target_tags   = ["http-server"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    }
    "allow-inbound-http-access" = {
      direction     = "INGRESS"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["http-server"]
      allow = [{
        protocol = "tcp"
        ports    = ["80"]
      }]
    }
  }

  cloud_nat_configs = ["us-central1"]
}

resource "google_service_account" "gke_sa" {
  account_id   = "gke-sa"
  display_name = "GKE Service Account" 
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



module "" {
  source = "./modules/gke"
}

module "k8s-mario" {
  source = "./modules/k8s"
  cluster_name = "mario-cluster"
  cluster_location = "us-central1"
  min_replicas = 1
  max_replicas = 5
  image = "kaminskypavel/mario:latest"
}