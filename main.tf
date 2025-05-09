# Create a VPC network and subnet
module "prod-vpc" {
  source       = "./modules/network"
  project_id   = var.project_id
  network_name = "prod"

  subnets = {
    "prod-central-vpc" = {
      region = "us-central1"
      cidr   = "10.0.0.0/24"
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

module "prod_central_cluster" {
  source       = "./modules/gke"
  project_id   = var.project_id
  cluster_name = "prod-cluster-central"
  region       = "us-central1"
  network_id   = module.prod-vpc.network_id
  subnet_id    = module.prod-vpc.subnet_ids["prod-central-vpc"]

  authorized_networks = [
    {
      cidr_block   = "10.0.0.0/24"
      display_name = "Prod Central VPC"
    }
  ]
}