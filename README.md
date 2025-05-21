# gcp-gke-mario

Deploy Super Mario in the browser using GKE (Google Kubernetes Engine) with a multi-regional infrastructure.

## Architecture

This project deploys:

- A VPC network with subnets in three regions (us-east5, us-central1, us-west4)
- Three GKE clusters, one in each region
- Cloud NAT in each region for internet egress
- Super Mario browser game deployed to the central cluster
- Gateway API enabled for advanced traffic management
- Automated horizontal pod scaling

## Prerequisites

### Required Tools

- Google Cloud SDK
- Terraform ~> 1.11.0
- kubectl

### Required GCP APIs

```bash
compute.googleapis.com
container.googleapis.com
cloudresourcemanager.googleapis.com
iam.googleapis.com
serviceusage.googleapis.com
monitoring.googleapis.com
logging.googleapis.com
containerregistry.googleapis.com
gkehub.googleapis.com
anthosconfigmanagement.googleapis.com
```

## Quick Start

1. Clone this repository:

```bash
git clone https://github.com/yourusername/gcp-gke-mario.git
cd gcp-gke-mario
```

2. Initialize and apply the Terraform configuration:

```bash
# Make the setup script executable
chmod +x setup.sh

# Run the setup script
./setup.sh
```

3. After completion, the script will output the URL where you can access the Mario game.

## Private Clusters

The GKE clusters are configured as private clusters with:

- Private nodes (no public IPs)
- Public control plane endpoint (restricted by authorized networks)
- Automated node upgrades and repairs
- Node auto-scaling
- Workload identity enabled
- Binary authorization enforced
- Regular release channel for stable updates

## Clean Up

To destroy all resources:

```bash
terraform destroy -auto-approve
```

## Note

It may take 5-10 minutes after deployment for the load balancer to be fully provisioned and the game to be accessible.

## License

This project is licensed under the GNU General Public License v3.0
