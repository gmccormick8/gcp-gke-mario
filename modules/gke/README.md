# GCP GKE Autopilot Module

This module creates a secure Google Kubernetes Engine (GKE) Autopilot cluster with public access to workloads.

## Features

- GKE Autopilot mode for automated management
- Private nodes with public control plane access
- Workload Identity enabled
- Network Policy enforcement
- Binary Authorization
- Public load balancer access to workloads

## Required APIs

```bash
container.googleapis.com              # Kubernetes Engine API
compute.googleapis.com               # Compute Engine API
cloudresourcemanager.googleapis.com  # Cloud Resource Manager API
iam.googleapis.com                  # Identity and Access Management API
serviceusage.googleapis.com         # Service Usage API
monitoring.googleapis.com           # Cloud Monitoring API
logging.googleapis.com              # Cloud Logging API
```

## Usage

```hcl
module "gke_cluster" {
  source = "./modules/gke"

  project_id   = "my-project-id"
  cluster_name = "my-cluster"
  region       = "us-central1"

  network_name = "my-vpc"
  subnet_name  = "my-subnet"

  master_ipv4_cidr_block = "172.16.0.0/28"
}
```

## Requirements

- Terraform >= 1.11.0
- Google Provider >= 6.30.0
- A VPC network with secondary IP ranges configured for pods and services
- Appropriate IAM permissions to create GKE clusters

## Variables

| Name                   | Description                    | Type   | Required |
| ---------------------- | ------------------------------ | ------ | -------- |
| project_id             | The GCP project ID             | string | yes      |
| cluster_name           | The name of the cluster        | string | yes      |
| region                 | The region to host the cluster | string | yes      |
| network_name           | The VPC network name           | string | yes      |
| subnet_name            | The subnet name                | string | yes      |
| master_ipv4_cidr_block | CIDR for the control plane     | string | no       |

## Outputs

| Name             | Description                              |
| ---------------- | ---------------------------------------- |
| cluster_id       | The full ID of the GKE cluster           |
| cluster_name     | The name of the GKE cluster              |
| cluster_endpoint | The IP address of the cluster master     |
| cluster_location | The cluster's location                   |
| master_auth      | The cluster's authentication information |

## Security Features

- Private nodes with public endpoint
- Workload Identity for secure service account management
- Network Policy enforcement for pod-to-pod traffic control
- Binary Authorization for secure deployments
- Vulnerability scanning enabled
- Master authorized networks configured for public access
- Regular release channel for stable updates

## Limitations

- Autopilot mode has some restrictions on pod configurations
- Node pools cannot be manually configured
- Some Kubernetes features may not be available

## Network Requirements

The VPC must have secondary IP ranges configured for:

- Pods: `[subnet-name]-pods`
- Services: `[subnet-name]-services`

## License

This module is licensed under the GNU General Public License v3.0
