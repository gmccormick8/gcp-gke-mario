# gcp-gke-mario

Deploy Super Mario in the browser using GKE (Google Kubernetes Engine) with multi-regional infrastructure and global load balancing.

## Architecture

This project deploys:

- A VPC network with subnets in three regions (us-east5, us-central1, us-west4)
- Three GKE clusters, one in each region, configured in a fleet
- Cloud NAT in each region for internet egress
- Gateway API for multi-cluster load balancing
- Super Mario browser game deployed across all clusters
- Global load balancer for optimal user routing
- Automated horizontal pod scaling in each cluster

## Features

- Multi-regional deployment for high availability
- Global load balancing with Gateway API
- Automatic failover between regions
- Location-based routing for reduced latency
- Fleet management for centralized control
- Secure private GKE clusters
- Automated scaling based on demand

## Prerequisites

### Required Software

- Google Cloud SDK installed and configured
- Terraform ~> 1.11.0
- kubectl (can be installed via gcloud)
- A Google Cloud Project with billing enabled

### Required GCP APIs

The setup script will automatically enable these APIs:

```bash
compute.googleapis.com
container.googleapis.com
iam.googleapis.com
gkehub.googleapis.com
```

## Quick Start

1. Clone this repository:

```bash
git clone https://github.com/yourusername/gcp-gke-mario.git
cd gcp-gke-mario
```

2. Run the setup script:

```bash
 bash setup.sh
```

The script will:

- Enable required APIs
- Check/update Terraform version
- Create terraform.tfvars with your project ID and current IP
- Initialize Terraform
- Show the planned changes
- Apply the configuration (with your approval)

## Architecture Details

### Networking

- Custom VPC network with regional subnets
- Private GKE clusters with public control plane endpoints
- Cloud NAT gateways for outbound internet access
- Global load balancing via Gateway API

### Kubernetes Infrastructure

- Three regional GKE clusters
- Fleet registration for multi-cluster management
- Workload identity enabled
- Binary authorization enforced
- Node auto-scaling configured
- Regular release channel for updates

### Application Deployment

- Helm-based deployment across all clusters
- Horizontal Pod Autoscaling
- Resource limits and requests defined
- Readiness probes configured
- Non-root container execution

### Load Balancing

- Multi-cluster Gateway API configuration
- Health checking and automatic failover
- Geographic-based traffic routing
- Equal traffic distribution across healthy endpoints

## Monitoring & Management

Access Kubernetes resources:

```bash
# Configure kubectl context
gcloud container clusters get-credentials [CLUSTER_NAME] --region [REGION]

# View deployments
kubectl get deployments -n mario

# Check pod status
kubectl get pods -n mario

# View Gateway API resources
kubectl get gateway,httproute -n mario
```

## Clean Up

To destroy all resources:

```bash
terraform destroy -auto-approve
```

This will remove:

- All GKE clusters
- The VPC network and subnets
- Cloud NAT gateways
- Load balancers
- Associated service accounts

## Notes

- Initial deployment takes approximately 15-20 minutes
- Load balancer provisioning may take an additional 5-10 minutes
- The Mario game will be available at the URL provided in the terraform output
- Resource usage is optimized for cost-effectiveness while maintaining reliability

## License

This project is licensed under the GNU General Public License v3.0
