locals {
  clusters = {
    east = {
      # GKE cluster config
      cluster_name          = "east-cluster"
      region                = "us-east5"
      zone                  = "us-east5-c"
      subnet_key            = "prod-east-vpc"
      pods_network_name     = "prod-east-pods"
      services_network_name = "prod-east-services"
      master_ipv4_cidr      = "172.16.0.0/28"

      # K8s deployment config
      config_cluster = false
    }
    central = {
      # GKE cluster config
      cluster_name          = "central-cluster"
      region                = "us-central1"
      zone                  = "us-central1-c"
      subnet_key            = "prod-central-vpc"
      pods_network_name     = "prod-central-pods"
      services_network_name = "prod-central-services"
      master_ipv4_cidr      = "172.16.1.0/28"

      # K8s deployment config
      config_cluster = true
    }
    west = {
      # GKE cluster config
      cluster_name          = "west-cluster"
      region                = "us-west4"
      zone                  = "us-west4-c"
      subnet_key            = "prod-west-vpc"
      pods_network_name     = "prod-west-pods"
      services_network_name = "prod-west-services"
      master_ipv4_cidr      = "172.16.2.0/28"

      # K8s deployment config
      config_cluster = false
    }
  }
}

# Create a VPC network and subnets
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

module "gke_clusters" {
  for_each = local.clusters
  source   = "./modules/gke"

  project_id             = var.project_id
  cluster_name           = each.value.cluster_name
  zone                   = each.value.zone
  network_name           = module.prod-vpc.network_self_link
  subnet_name            = module.prod-vpc.subnets[each.value.subnet_key].self_link
  pods_network_name      = each.value.pods_network_name
  services_network_name  = each.value.services_network_name
  master_ipv4_cidr_block = each.value.master_ipv4_cidr
  public_ip              = var.public_ip
  min_node_count         = 1
  max_node_count         = 3
  machine_type           = "e2-small"
  disk_size_gb           = 25
  disk_type              = "pd-standard"

  depends_on = [
    module.prod-vpc
  ]
}

# Configure GKE Hub and enable Multi-Cluster Services (MCS)
resource "google_gke_hub_feature" "mcs" {
  name     = "multiclusterservicediscovery"
  project  = var.project_id
  location = "global"

  depends_on = [
    module.gke_clusters,
    terraform_data.fleet_membership_cleanup
  ]
}

# Register clusters with GKE Hub and enable Multi-Cluster Ingress (MCI)
resource "google_gke_hub_feature" "mci" {
  name     = "multiclusteringress"
  project  = var.project_id
  location = "global"

  spec {
    multiclusteringress {
      config_membership = "projects/${var.project_id}/locations/${local.clusters["central"].region}/memberships/${module.gke_clusters["central"].cluster_name}"
    }
  }

  depends_on = [
    module.gke_clusters,
    terraform_data.fleet_membership_cleanup
  ]
}

# Deploy Mario application to the east GKE cluster
module "k8s-mario-east" {
  source           = "./modules/k8s"
  cluster_name     = module.gke_clusters["east"].cluster_name
  cluster_endpoint = module.gke_clusters["east"].cluster_endpoint
  cluster_ca_cert  = module.gke_clusters["east"].master_auth.cluster_ca_certificate
  min_replicas     = 1
  max_replicas     = 5
  image            = "sevenajay/mario:latest"
  config_cluster   = local.clusters.east.config_cluster
  providers = {
    kubernetes = kubernetes.east
    helm       = helm.east
  }

  depends_on = [
    module.gke_clusters["east"],
    google_gke_hub_feature.mcs,
    google_gke_hub_feature.mci
  ]
}

# Deploy Mario application to the central GKE cluster
module "k8s-mario-central" {
  source           = "./modules/k8s"
  cluster_name     = module.gke_clusters["central"].cluster_name
  cluster_endpoint = module.gke_clusters["central"].cluster_endpoint
  cluster_ca_cert  = module.gke_clusters["central"].master_auth.cluster_ca_certificate
  min_replicas     = 1
  max_replicas     = 5
  image            = "sevenajay/mario:latest"
  config_cluster   = local.clusters.central.config_cluster
  providers = {
    kubernetes = kubernetes.central
    helm       = helm.central
  }

  depends_on = [
    module.gke_clusters["central"],
    google_gke_hub_feature.mcs,
    google_gke_hub_feature.mci
  ]
}

# Deploy Mario application to the west GKE cluster
module "k8s-mario-west" {
  source           = "./modules/k8s"
  cluster_name     = module.gke_clusters["west"].cluster_name
  cluster_endpoint = module.gke_clusters["west"].cluster_endpoint
  cluster_ca_cert  = module.gke_clusters["west"].master_auth.cluster_ca_certificate
  min_replicas     = 1
  max_replicas     = 5
  image            = "sevenajay/mario:latest"
  config_cluster   = local.clusters.west.config_cluster
  providers = {
    kubernetes = kubernetes.west
    helm       = helm.west
  }

  depends_on = [
    module.gke_clusters["west"],
    google_gke_hub_feature.mcs,
    google_gke_hub_feature.mci
  ]
}

# Cleanup dynamically created firewall rules for GKE clusters
resource "terraform_data" "gke_fw_cleanup" {
  triggers_replace = {
    project_id = var.project_id
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      RULES=$(gcloud compute firewall-rules list --project=${self.triggers_replace.project_id} --filter='name~^gke-.*mcsd$' --format='value(name)')
      if [ ! -z "$RULES" ]; then
        for RULE in $RULES; do
          echo "Deleting firewall rule: $RULE"
          gcloud compute firewall-rules delete $RULE --project=${self.triggers_replace.project_id} --quiet
        done
      else
        echo "No matching firewall rules found to delete"
      fi
    EOT
  }

  depends_on = [ module.prod-vpc ]
}

# Cleanup dynamically created fleet memberships
resource "terraform_data" "fleet_membership_cleanup" {
  triggers_replace = {
    project_id = var.project_id
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "Unregistering clusters from fleet..."
      for CLUSTER in central east west; do
        gcloud container clusters update "$${CLUSTER}-cluster" \
          --project=${self.triggers_replace.project_id} \
          --location=$(gcloud container clusters list --project=${self.triggers_replace.project_id} --filter="name=$${CLUSTER}-cluster" --format="value(location)") \
          --unregister-fleet \
          --quiet || true
      done

      # Wait for unregistration to complete
      echo "Waiting 90 seconds for fleet unregistration to complete..."
      sleep 90
    EOT
  }
}
