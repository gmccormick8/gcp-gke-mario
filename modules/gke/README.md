# GKE Cluster Module for Multi-Region Infrastructure

Creates a GKE cluster with Gateway API support, private nodes, and multi-cluster capabilities.

## Features

- **Private Infrastructure**

  - Private nodes with public control plane access restricted to:
    - Google Compute Engine Public IPs (for Cloud Shell and Google Cloud Console access)
    - A single whitelisted IP specified via public_ip variable (for direct kubectl access)
  - No bastion host required for secure control plane access
  - VPC-native networking
  - Cloud NAT for egress
  - IAP tunnel access

- **Security**

  - Workload identity enabled
  - Shielded nodes with secure boot
  - Binary authorization
  - Minimal IAM permissions
  - Private nodes only

- **Reliability**

  - Auto-scaling node pool
  - Auto-upgrade enabled
  - Auto-repair enabled
  - Regular release channel
  - Rolling updates

- **Gateway API**
  - Standard channel enabled
  - Multi-cluster support
  - Fleet registration
  - Global load balancing ready

## Usage

Basic example:

```hcl
module "gke_cluster" {
  source = "./modules/gke"

  project_id             = "my-project"
  cluster_name          = "prod-cluster"
  zone                  = "us-central1-a"
  network_name          = module.vpc.network_self_link
  subnet_name           = module.vpc.subnets["my-subnet"].self_link
  master_ipv4_cidr_block = "172.16.0.0/28"
  pods_network_name     = "pods"
  services_network_name = "services"
  public_ip             = "35.35.35.35"
}
```

Advanced example with customizations:

```hcl
module "gke_cluster" {
  source = "./modules/gke"

  project_id             = "my-project"
  cluster_name          = "demo-cluster"
  zone                  = "us-east1-a"
  network_name          = module.vpc.network_self_link
  subnet_name           = module.vpc.subnets["demo-subnet"].self_link
  master_ipv4_cidr_block = "172.16.1.0/28"
  pods_network_name     = "pods"
  services_network_name = "services"
  public_ip             = "35.35.35.36"

  # Node pool customization
  min_node_count = 2
  max_node_count = 10
  machine_type   = "e2-standard-4"
  disk_size_gb   = 100
  disk_type      = "pd-ssd"
}
```

## Requirements

- Terraform ~> 1.11
- Google Provider ~> 6.30
- Google Beta Provider ~> 6.30
- APIs enabled:
  - compute.googleapis.com
  - container.googleapis.com
  - gkehub.googleapis.com
  - cloudresourcemanager.googleapis.com
  - trafficdirector.googleapis.com
  - multiclusterservicediscovery.googleapis.com
  - multiclusteringress.googleapis.com
  - anthos.googleapis.com

## Variables

### Required

| Name                   | Description                  | Type   |
| ---------------------- | ---------------------------- | ------ |
| project_id             | GCP Project ID               | string |
| cluster_name           | Name for GKE cluster         | string |
| zone                   | Zone to host the cluster     | string |
| network_name           | VPC network self-link        | string |
| subnet_name            | Subnet self-link             | string |
| master_ipv4_cidr_block | Control plane CIDR           | string |
| pods_network_name      | Secondary range for pods     | string |
| services_network_name  | Secondary range for services | string |
| public_ip              | Authorized network IP        | string |

### Optional

| Name           | Description            | Type   | Default       |
| -------------- | ---------------------- | ------ | ------------- |
| min_node_count | Minimum nodes per zone | number | 1             |
| max_node_count | Maximum nodes per zone | number | 2             |
| machine_type   | Node pool machine type | string | "e2-small"    |
| disk_size_gb   | Node disk size in GB   | number | 25            |
| disk_type      | Node disk type         | string | "pd-standard" |

## Outputs

| Name             | Description                |
| ---------------- | -------------------------- |
| cluster_id       | Full cluster ID            |
| cluster_name     | Cluster name               |
| cluster_location | Cluster location           |
| cluster_endpoint | Control plane endpoint     |
| master_auth      | CA certificate (sensitive) |

## Node Pool Configuration

Default node pool settings:

```yaml
autoscaling:
  min_count: 1
  max_count: 2

node_config:
  machine_type: e2-small
  disk_size_gb: 25
  disk_type: pd-standard
  oauth_scopes:
    - cloud-platform

security:
  secure_boot: true
  integrity_monitoring: true
  private_nodes: true

management:
  auto_upgrade: true
  auto_repair: true
  surge_upgrade: true
```

## IAM Roles

Service account permissions:

- roles/container.nodeServiceAgent
- roles/compute.networkViewer
- roles/container.admin

## Best Practices Implemented

1. Network Security

   - Use private nodes
   - Enable master authorized networks (limited to Google Compute Engine Public IPs and an IP that can be spcified when the module is called)
   - Configure Cloud NAT for egress

2. Node Security

   - Enable Workload Identity
   - Use shielded nodes
   - Enable secure boot
   - Minimize OAuth scopes

3. Operational Excellence
   - Enable auto-upgrade
   - Enable auto-repair
   - Configure suitable node counts
   - Use rolling updates

## Limitations

- Single zone only
- Public control plane
- One node pool
- Standard release channel only

## Troubleshooting

Common issues and solutions:

1. Control Plane Access

```bash
# Test connectivity
gcloud container clusters get-credentials CLUSTER_NAME --zone ZONE
kubectl cluster-info
```

2. Node Pool Issues

```bash
# Check node status
kubectl get nodes
kubectl describe node NODE_NAME
```

3. Workload Identity

```bash
# Verify configuration
kubectl describe serviceaccount SERVICEACCOUNT_NAME
gcloud container clusters describe CLUSTER_NAME
```

## License

GNU General Public License v3.0
