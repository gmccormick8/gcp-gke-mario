# GCP GKE Cluster Terraform Module

This module creates a secure Google Kubernetes Engine (GKE) cluster with associated resources including a dedicated service account, node pool, and Fleet membership.

## Features

- Private GKE cluster with authorized networks
- Workload Identity configuration
- Auto-scaling node pool with configurable limits
- Shielded nodes with secure boot
- Fleet membership for centralized management
- Scheduled maintenance windows
- Regular release channel

## Usage

Basic usage with minimal configuration:

```hcl
module "gke" {
  source       = "./modules/gke"
  project_id   = "my-project"
  cluster_name = "my-cluster"
  zone       = "us-central1-a"
  network_id   = module.network.network_id
  subnet_id    = module.network.subnet_ids["subnet-name"]
}
```

Advanced usage with custom configuration:

```hcl
module "gke" {
  source       = "./modules/gke"
  project_id   = "my-project"
  cluster_name = "my-cluster"
  zone       = "us-central1-a"
  network_id   = module.network.network_id
  subnet_id    = module.network.subnet_ids["subnet-name"]

  master_ipv4_cidr_block = "172.16.0.0/28"
  machine_type           = "e2-standard-2"

  total_min_node_count = 2
  total_max_node_count = 5

  authorized_networks = [
    {
      cidr_block   = "10.0.0.0/24"
      display_name = "VPN Network"
    }
  ]
}
```

## Requirements

- Terraform >= 1.0
- Google Provider >= 4.0
- Google Project with necessary APIs enabled:
  - container.googleapis.com
  - gkeconnect.googleapis.com
  - gkehub.googleapis.com

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID | string | - | yes |
| cluster_name | Name of the GKE cluster | string | - | yes |
| zone | Zone where the cluster will be created | string | - | yes |
| network_id | VPC network ID | string | - | yes |
| subnet_id | Subnet ID | string | - | yes |
| master_ipv4_cidr_block | CIDR block for the master network | string | "172.16.0.0/28" | no |
| pods_ipv4_cidr_block | CIDR block for pods | string | "10.40.0.0/14" | no |
| services_ipv4_cidr_block | CIDR block for services | string | "10.44.0.0/20" | no |
| authorized_networks | List of authorized networks that can access the cluster | list(object) | [] | no |
| total_min_node_count | Minimum number of nodes across all zones | number | 1 | no |
| total_max_node_count | Maximum number of nodes across all zones | number | 3 | no |
| machine_type | Machine type for nodes | string | "e2-micro" | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the GKE cluster |
| fleet_membership_id | The ID of the Fleet membership |
| service_account_id | The ID of the GKE service account |

## Security Features

- Private cluster with no public endpoint
- Authorized networks for master access
- Workload Identity for pod authentication
- Shielded nodes with secure boot and integrity monitoring
- Auto-upgrading and auto-repairing nodes
- Regular security patches via maintenance windows

## License

This module is licensed under the GNU General Public License v3.0
