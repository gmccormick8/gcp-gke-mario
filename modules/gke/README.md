# GCP GKE Cluster Module

This module creates a secure Google Kubernetes Engine (GKE) cluster with private nodes and configurable node pools.

## Features

- Private nodes with public control plane access
- Workload Identity enabled
- Network Policy enforcement
- Binary Authorization
- Auto-scaling node pool
- Regular release channel updates
- Node service account with minimal permissions
- Gateway API support
- Fleet membership ready for multi-cluster management
- Standardized membership ID format for fleet enrollment

## Required APIs

```bash
container.googleapis.com
compute.googleapis.com
cloudresourcemanager.googleapis.com
iam.googleapis.com
gkehub.googleapis.com
anthosconfigmanagement.googleapis.com
```

## Usage

```hcl
module "gke_cluster" {
  source = "./modules/gke"

  project_id             = "my-project-id"
  cluster_name          = "my-cluster"
  zone                  = "us-central1-a"
  network_name          = "my-vpc"
  subnet_name           = "my-subnet"
  pods_network_name     = "my-pods-range"
  services_network_name = "my-services-range"
  master_ipv4_cidr_block = "172.16.0.0/28"
  public_ip             = "35.35.35.35"

  min_node_count = 1
  max_node_count = 3
  machine_type   = "e2-small"
  disk_size_gb   = 25
  disk_type      = "pd-standard"
}
```

## Requirements

- Terraform ~> 1.11
- Google Provider ~> 6.30
- A VPC network with secondary IP ranges configured for pods and services
- Appropriate IAM permissions to create GKE clusters

## Variables

| Name                   | Description                              | Type   | Default       |
| ---------------------- | ---------------------------------------- | ------ | ------------- |
| project_id             | The GCP project ID                       | string | required      |
| cluster_name           | The name of the cluster                  | string | required      |
| zone                   | The zone to host the cluster             | string | required      |
| network_name           | The VPC network to host the cluster      | string | required      |
| subnet_name            | The subnetwork to host the cluster       | string | required      |
| master_ipv4_cidr_block | The IP range for the control plane       | string | required      |
| pods_network_name      | The name of secondary range for pods     | string | required      |
| services_network_name  | The name of secondary range for services | string | required      |
| public_ip              | IP to allow cluster access from          | string | required      |
| min_node_count         | Minimum number of nodes                  | number | 1             |
| max_node_count         | Maximum number of nodes                  | number | 2             |
| machine_type           | Machine type for nodes                   | string | "e2-small"    |
| disk_size_gb           | Node disk size in GB                     | number | 25            |
| disk_type              | Node disk type                           | string | "pd-standard" |

## Outputs

| Name                  | Description                                       |
| --------------------- | ------------------------------------------------- |
| cluster_id            | The full ID of the GKE cluster                    |
| cluster_name          | The name of the GKE cluster                       |
| cluster_location      | The cluster's location                            |
| cluster_endpoint      | The IP address of the cluster master              |
| master_auth           | The cluster's authentication information          |
| fleet_membership_id   | The ID used for fleet membership registration     |
| gke_hub_membership_id | The full resource ID for GKE Hub fleet membership |

## Security Features

- Private nodes with public endpoint
- Workload Identity for secure service account management
- Network Policy enforcement
- Binary Authorization enabled
- Regular release channel for stable updates
- Minimal IAM permissions for node service account
- Master authorized networks configuration

## Network Requirements

The VPC must have secondary IP ranges configured for:

- Pods network (specified by pods_network_name)
- Services network (specified by services_network_name)

## Node Pool Configuration

The module creates a node pool with:

- Autoscaling between min_node_count and max_node_count
- Automatic upgrades and repairs
- Private nodes
- Configurable machine type and disk specifications
- Custom service account with minimal permissions

## Fleet Membership Configuration

The module provides standardized outputs for fleet membership:

- `fleet_membership_id`: Used for registering the cluster with a fleet
- `gke_hub_membership_id`: Full resource ID path for the cluster's fleet membership

These outputs follow the format:

- Membership ID: `{cluster_name}-membership`
- Resource ID: `//gkehub.googleapis.com/projects/{project_id}/locations/global/memberships/{cluster_name}-membership`

## License

This module is licensed under the GNU General Public License v3.0
