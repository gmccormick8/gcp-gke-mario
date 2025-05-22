# Create a VPC network and subnet
module "prod-vpc" {
  source       = "./modules/network"
  project_id   = var.project_id
  network_name = "prod"

  subnets = {
    "prod-east-vpc" = {
      region = "us-east5"
      cidr   = "10.0.0.0/24"
      secondary_ranges = {
        "prod-east-pods" = {
          ip_cidr_range = "192.168.0.0/19"
        }
        "prod-east-services" = {
          ip_cidr_range = "192.168.32.0/19"
        }
      }
    }
    "prod-central-vpc" = {
      region = "us-central1"
      cidr   = "10.0.1.0/24"
      secondary_ranges = {
        "prod-central-pods" = {
          ip_cidr_range = "192.168.64.0/19"
        }
        "prod-central-services" = {
          ip_cidr_range = "192.168.96.0/19"
        }
      }
    }
    "prod-west-vpc" = {
      region = "us-west4"
      cidr   = "10.0.2.0/24"
      secondary_ranges = {
        "prod-west-pods" = {
          ip_cidr_range = "192.168.128.0/19"
        }
        "prod-west-services" = {
          ip_cidr_range = "192.168.160.0/19"
        }
      }
    }
  }

  cloud_nat_configs = ["us-east5", "us-central1", "us-west4"]
}

module "prod-east-cluster" {
  source                 = "./modules/gke"
  project_id             = var.project_id
  cluster_name           = "east-cluster"
  zone                   = "${module.prod-vpc.subnets["prod-east-vpc"].region}-c"
  network_name           = module.prod-vpc.network_self_link
  subnet_name            = module.prod-vpc.subnets["prod-east-vpc"].self_link
  pods_network_name      = "prod-east-pods"
  services_network_name  = "prod-east-services"
  master_ipv4_cidr_block = "172.16.0.0/28"
  public_ip              = var.public_ip
  min_node_count         = 1
  max_node_count         = 3
  machine_type           = "e2-small"
  disk_size_gb           = 25
  disk_type              = "pd-standard"
}

module "prod-central-cluster" {
  source                 = "./modules/gke"
  project_id             = var.project_id
  cluster_name           = "central-cluster"
  zone                   = "${module.prod-vpc.subnets["prod-central-vpc"].region}-c"
  network_name           = module.prod-vpc.network_self_link
  subnet_name            = module.prod-vpc.subnets["prod-central-vpc"].self_link
  pods_network_name      = "prod-central-pods"
  services_network_name  = "prod-central-services"
  master_ipv4_cidr_block = "172.16.1.0/28"
  public_ip              = var.public_ip
  min_node_count         = 1
  max_node_count         = 3
  machine_type           = "e2-small"
  disk_size_gb           = 25
  disk_type              = "pd-standard"
}

module "prod-west-cluster" {
  source                 = "./modules/gke"
  project_id             = var.project_id
  cluster_name           = "west-cluster"
  zone                   = "${module.prod-vpc.subnets["prod-west-vpc"].region}-c"
  network_name           = module.prod-vpc.network_self_link
  subnet_name            = module.prod-vpc.subnets["prod-west-vpc"].self_link
  pods_network_name      = "prod-west-pods"
  services_network_name  = "prod-west-services"
  master_ipv4_cidr_block = "172.16.2.0/28"
  public_ip              = var.public_ip
  min_node_count         = 1
  max_node_count         = 2
  machine_type           = "e2-small"
  disk_size_gb           = 25
  disk_type              = "pd-standard"
}

module "k8s-mario" {
  source     = "./modules/k8s"
  project_id = var.project_id
  clusters = {
    east = {
      name     = module.prod-east-cluster.cluster_name
      location = module.prod-east-cluster.cluster_location
      endpoint = module.prod-east-cluster.cluster_endpoint
      ca_cert  = module.prod-east-cluster.master_auth.cluster_ca_certificate
    }
    central = {
      name     = module.prod-central-cluster.cluster_name
      location = module.prod-central-cluster.cluster_location
      endpoint = module.prod-central-cluster.cluster_endpoint
      ca_cert  = module.prod-central-cluster.master_auth.cluster_ca_certificate
    }
    west = {
      name     = module.prod-west-cluster.cluster_name
      location = module.prod-west-cluster.cluster_location
      endpoint = module.prod-west-cluster.cluster_endpoint
      ca_cert  = module.prod-west-cluster.master_auth.cluster_ca_certificate
    }
  }
  min_replicas = 1
  max_replicas = 5
  image        = "sevenajay/mario:latest"
}
