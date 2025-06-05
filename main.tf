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
    module.prod-east-cluster,
    module.prod-central-cluster,
    module.prod-west-cluster
  ]
}

resource "google_gke_hub_feature" "mci" {
  name     = "multiclusteringress"
  project  = var.project_id
  location = "global"

  spec {
    multiclusteringress {
      config_membership = "projects/${var.project_id}/locations/us-central1/memberships/${module.prod-central-cluster.cluster_name}"
    }
  }

  depends_on = [google_gke_hub_feature.mcs]
}

# Add wait for clusters to be ready
resource "time_sleep" "wait_for_clusters" {
  create_duration = "120s"

  triggers = {
    cluster_east    = module.prod-east-cluster.cluster_name
    cluster_central = module.prod-central-cluster.cluster_name
    cluster_west    = module.prod-west-cluster.cluster_name
    mcs_feature     = google_gke_hub_feature.mcs.id
    mci_feature     = google_gke_hub_feature.mci.id
  }
}

module "k8s-mario-east" {
  source           = "./modules/k8s"
  project_id       = var.project_id
  cluster_name     = module.prod-east-cluster.cluster_name
  cluster_location = module.prod-east-cluster.cluster_location
  cluster_endpoint = module.prod-east-cluster.cluster_endpoint
  cluster_ca_cert  = module.prod-east-cluster.master_auth.cluster_ca_certificate
  min_replicas     = 1
  max_replicas     = 5
  image            = "sevenajay/mario:latest"
  config_cluster   = false
}

module "k8s-mario-central" {
  source           = "./modules/k8s"
  project_id       = var.project_id
  cluster_name     = module.prod-central-cluster.cluster_name
  cluster_location = module.prod-central-cluster.cluster_location
  cluster_endpoint = module.prod-central-cluster.cluster_endpoint
  cluster_ca_cert  = module.prod-central-cluster.master_auth.cluster_ca_certificate
  min_replicas     = 1
  max_replicas     = 5
  image            = "sevenajay/mario:latest"
  config_cluster   = true
}

module "k8s-mario-west" {
  source           = "./modules/k8s"
  project_id       = var.project_id
  cluster_name     = module.prod-west-cluster.cluster_name
  cluster_location = module.prod-west-cluster.cluster_location
  cluster_endpoint = module.prod-west-cluster.cluster_endpoint
  cluster_ca_cert  = module.prod-west-cluster.master_auth.cluster_ca_certificate
  min_replicas     = 1
  max_replicas     = 5
  image            = "sevenajay/mario:latest"
  config_cluster   = false
}

# Cleanup dynamically created firewall rules for GKE clusters
resource "terraform_data" "gke_fw_cleanup" {
  triggers_replace = {
    project_id = var.project_id
    central_cluster = module.prod-central-cluster.cluster_name
    west_cluster = module.prod-west-cluster.cluster_name
    east_cluster = module.prod-east-cluster.cluster_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = "gcloud compute firewall-rules delete $(gcloud compute firewall-rules list --project=${self.triggers_replace.project_id} --filter='name~^gke-.*-.*-[0-9a-f]+-mcsd$' --format='value(name)') --project=${self.triggers_replace.project_id} --quiet"
  }
}
