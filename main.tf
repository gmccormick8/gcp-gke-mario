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
          ip_cidr_range = "192.168.0.0/17"
        }
        "prod-central-services" = {
          ip_cidr_range = "192.168.128.0/17"
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

module "cluster-central" {
  source                 = "./modules/gke"
  project_id             = var.project_id
  cluster_name           = "central-cluster"
  region                 = "us-central1"
  network_name           = module.prod-vpc.network_self_link
  subnet_name            = module.prod-vpc.subnets["prod-central-vpc"].self_link
  pods_cidr              = module.prod-vpc.subnets["prod-central-vpc"].secondary_ranges["prod-central-pods"].self_link
  services_cidr          = module.prod-vpc.subnets["prod-central-vpc"].secondary_ranges["prod-central-services"].self_link
  master_ipv4_cidr_block = "172.16.0.0/28"
}

module "k8s-mario" {
  source                 = "./modules/k8s"
  cluster_name           = module.cluster-central.cluster_name
  cluster_location       = module.cluster-central.cluster_location
  cluster_endpoint       = module.cluster-central.cluster_endpoint
  cluster_ca_certificate = module.cluster-central.master_auth.cluster_ca_certificate
  min_replicas           = 1
  max_replicas           = 5
  image                  = "docker.io/sevenajay/mario:latest"
}
