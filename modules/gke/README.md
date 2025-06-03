# Google Kubernetes Engine Module

This module creates a secure, production-ready GKE cluster with private nodes, workload identity, and Gateway API support.

## Features

- Private GKE cluster with public control plane
- Workload identity enabled
- Custom service account with least privilege
- Gateway API support
- Binary authorization
- Auto-scaling node pool
- Auto-upgrade and auto-repair enabled
- Shielded nodes with secure boot
- VPC-native networking
- Regular release channel

## Usage

```hcl
module "gke_cluster" {
  source = "./modules/gke"

  project_id             = "my-project"
  cluster_name          = "prod-cluster"
  zone                  = "us-central1-a"
  network_name          = "vpc-network-self-link"
  subnet_name           = "subnet-self-link"
  pods_network_name     = "pods-range-name"
  services_network_name = "services-range-name"
  master_ipv4_cidr_block = "172.16.0.0/28"
  public_ip             = "35.35.35.35"

  # Optional configurations
  min_node_count = 1
  max_node_count = 5
  machine_type   = "e2-standard-2"
  disk_size_gb   = 50
  disk_type      = "pd-standard"
}
```

## Prerequisites

- Terraform ~> 1.11
- Google Provider ~> 6.30
- Required APIs enabled:
  - container.googleapis.com
  - containerregistry.googleapis.com
  - compute.googleapis.com
  - iam.googleapis.com
  - gkehub.googleapis.com

## Module Variables

| Name                   | Description                       | Type   | Default       | Required |
| ---------------------- | --------------------------------- | ------ | ------------- | :------: |
| project_id             | GCP Project ID                    | string | -             |   yes    |
| cluster_name           | Name of the GKE cluster           | string | -             |   yes    |
| zone                   | Zone to host the cluster          | string | -             |   yes    |
| network_name           | VPC network self-link             | string | -             |   yes    |
| subnet_name            | Subnet self-link                  | string | -             |   yes    |
| master_ipv4_cidr_block | Control plane IP CIDR             | string | -             |   yes    |
| pods_network_name      | Secondary range name for pods     | string | -             |   yes    |
| services_network_name  | Secondary range name for services | string | -             |   yes    |
| public_ip              | Authorized network IP             | string | -             |   yes    |
| min_node_count         | Minimum nodes per zone            | number | 1             |    no    |
| max_node_count         | Maximum nodes per zone            | number | 2             |    no    |
| machine_type           | Node pool machine type            | string | "e2-small"    |    no    |
| disk_size_gb           | Node disk size in GB              | number | 25            |    no    |
| disk_type              | Node disk type                    | string | "pd-standard" |    no    |

## Security Features

### Node Security

- Shielded nodes enabled
- Secure boot enforced
- Integrity monitoring enabled
- Private nodes only
- Workload identity for pod authentication

### Network Security

- Private cluster architecture
- Authorized networks configuration
- VPC-native networking
- Master authorized networks

### Access Control

- Dedicated service account with minimal IAM roles:
  - container.nodeServiceAgent
  - compute.networkViewer
  - container.admin

## Node Pool Configuration

The default node pool is configured with:

- Auto-scaling (configurable min/max)
- Auto-upgrade enabled
- Auto-repair enabled
- Secure boot
- OAuth scopes limited to cloud-platform
- Private nodes only
- Rolling updates (max surge: 1, max unavailable: 1)

## Outputs

| Name             | Description                        |
| ---------------- | ---------------------------------- |
| cluster_id       | Full ID of the GKE cluster         |
| cluster_name     | Name of the cluster                |
| cluster_location | Location of the cluster            |
| cluster_endpoint | Cluster control plane endpoint     |
| master_auth      | Cluster CA certificate (sensitive) |

## Fleet Registration

The cluster is automatically registered to your GKE fleet, enabling:

- Multi-cluster management
- Fleet-wide policies
- Anthos features (if enabled)
- Gateway API support

## Limitations

- Single zone cluster (for multi-zone, adjust the location)
- Public control plane endpoint
- Standard release channel only
- Single node pool

## Notes

- Initial cluster creation takes ~10-15 minutes
- Node pool auto-upgrade occurs during maintenance window
- Binary authorization defaults to project policy
- Workload identity uses default GCP project format
- Gateway API enabled with CHANNEL_STANDARD

## License

This module is licensed under the GNU General Public License v3.0
