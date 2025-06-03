locals {
  clusters = {
    east = {
      name             = "east-cluster"
      region           = "us-east5"
      master_cidr      = "172.16.0.0/28"
      subnet_key       = "prod-east-vpc"
      pods_network     = "prod-east-pods"
      services_network = "prod-east-services"
    }
    central = {
      name             = "central-cluster"
      region           = "us-central1"
      master_cidr      = "172.16.1.0/28"
      subnet_key       = "prod-central-vpc"
      pods_network     = "prod-central-pods"
      services_network = "prod-central-services"
    }
    west = {
      name             = "west-cluster"
      region           = "us-west4"
      master_cidr      = "172.16.2.0/28"
      subnet_key       = "prod-west-vpc"
      pods_network     = "prod-west-pods"
      services_network = "prod-west-services"
    }
  }

  k8s_deployments = {
    east = {
      config_cluster = false
    }
    central = {
      config_cluster = true
    }
    west = {
      config_cluster = false
    }
  }
}

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

module "prod-clusters" {
  for_each               = local.clusters
  source                 = "./modules/gke"
  project_id             = var.project_id
  cluster_name           = each.value.name
  zone                   = "${each.value.region}-c"
  network_name           = module.prod-vpc.network_self_link
  subnet_name            = module.prod-vpc.subnets[each.value.subnet_key].self_link
  pods_network_name      = each.value.pods_network
  services_network_name  = each.value.services_network
  master_ipv4_cidr_block = each.value.master_cidr
  public_ip              = var.public_ip
  min_node_count         = 1
  max_node_count         = 3
  machine_type           = "e2-small"
  disk_size_gb           = 25
  disk_type              = "pd-standard"
}

resource "google_gke_hub_feature" "mcs" {
  name     = "multiclusterservicediscovery"
  project  = var.project_id
  location = "global"

  depends_on = [
    module.prod-clusters["east"],
    module.prod-clusters["central"],
    module.prod-clusters["west"]
  ]
}

resource "google_gke_hub_feature" "mci" {
  name     = "multiclusteringress"
  project  = var.project_id
  location = "global"

  spec {
    multiclusteringress {
      config_membership = "projects/${var.project_id}/locations/us-central1/memberships/${module.prod-clusters["central"].cluster_name}"
    }
  }

  depends_on = [
    google_gke_hub_feature.mcs,
    module.prod-clusters["east"],
    module.prod-clusters["central"],
    module.prod-clusters["west"]
  ]
}

module "k8s-mario" {
  for_each         = local.k8s_deployments
  source           = "./modules/k8s"
  project_id       = var.project_id
  cluster_name     = module.prod-clusters[each.key].cluster_name
  cluster_location = module.prod-clusters[each.key].cluster_location
  cluster_endpoint = module.prod-clusters[each.key].cluster_endpoint
  cluster_ca_cert  = module.prod-clusters[each.key].master_auth.cluster_ca_certificate
  min_replicas     = 1
  max_replicas     = 5
  image            = "sevenajay/mario:latest"
  config_cluster   = each.value.config_cluster

  depends_on = [
    google_gke_hub_feature.mci,
    module.prod-clusters["east"],
    module.prod-clusters["central"],
    module.prod-clusters["west"]
  ]
}
