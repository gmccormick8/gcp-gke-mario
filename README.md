# GCP GKE Mario

[![Run Super Linter](https://github.com/gmccormick8/gcp-gke-mario/actions/workflows/super-linter.yml/badge.svg?branch=main)](https://github.com/gmccormick8/gcp-gke-mario/actions/workflows/super-linter.yml)

This project provides Infrastructure as Code (IaC) for deploying a highly-available browser-based Super Mario Web App leveraging modern cloud-native patterns including multi-cluster load balancing, Gateway API, and automated scaling. 
This project uses Zonal Google Kubernetes Engine (GKE) clusters, Helm charts, Multi-Cluster Services (MCS), and as well as a Global External Application Load Balancer across all clusters. 
This project is designed to run from the Google Cloud Shell using a user-friendly startup script. Simply clone this repository, run the script (following the prompts), and let Terraform do the rest!

## Features

- **Multi-Regional Infrastructure**

  - VPC network with subnets across US regions
  - Private GKE clusters with managed control planes
  - Cloud NAT for secure internet egress
  - Zonal failover and redundancy

- **Kubernetes Infrastructure**

  - Three GKE clusters in different regions
  - Fleet management for unified control
  - Gateway API for global load balancing
  - Automated horizontal pod scaling
  - Binary authorization enabled
  - Workload identity for security

- **Application Platform**
  - Super Mario browser game deployment
  - Global load balancer for optimal routing
  - Rate limiting (20 RPS per endpoint)
  - Maximum cluster capacity: 100 RPS
  - Total platform capacity: 300 RPS
  - Automatic failover between regions
  - Geographic-based request routing
  - Helm-based deployment automation

## Prerequisites

- Google Cloud SDK
- Terraform ~> 1.11.0
- Active GCP Project with billing
- Required permissions:
  - Project Owner or Editor
  - Kubernetes Engine Admin
  - Service Account Admin
- Required APIs:
  - compute.googleapis.com
  - container.googleapis.com
  - gkehub.googleapis.com
  - cloudresourcemanager.googleapis.com
  - trafficdirector.googleapis.com
  - multiclusterservicediscovery.googleapis.com
  - multiclusteringress.googleapis.com
  - anthos.googleapis.com

## Quick Start (Google Cloud Shell)

1. Clone this repository:

```bash
git clone https://github.com/gabrielmccormick/gcp-gke-mario.git && cd gcp-gke-mario
```

2. Run the setup script using either:

```bash
bash setup.sh OR ./setup.sh       # Interactive mode - will prompt for confirmations
bash setup.sh -y OR ./setup.sh -y    # Non-interactive mode - automatically approve all steps
```

The setup process:

- Enables required GCP APIs
- Verifies/updates Terraform version
- Automatically creates terraform.tfvars with the following values:
  - Your project ID based on the $DEVSHELL_PROJECT_ID - Google Cloud Shell ENV variable
  - Your current Public IP - Used to configure the Kubernetes Control Plane whitelist
- Initializes and applies Terraform configuration

**Note:** The setup script supports a `-y` flag for non-interactive deployments. This is useful for automated environments or when you want to skip all confirmation prompts. Example: `bash setup.sh -y`

## Manual Deployment

If you prefer not to use the setup script, follow these steps:

1. Enable required Google Cloud APIs:

```bash
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable gkehub.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable trafficdirector.googleapis.com
gcloud services enable multiclusterservicediscovery.googleapis.com
gcloud services enable multiclusteringress.googleapis.com
gcloud services enable anthos.googleapis.com
```

2. Create a `terraform.tfvars` file with your project ID and public IP:

```hcl
project_id = "your-project-id"
public_ip  = "your-public-ip"  # Get this from https://ifconfig.me
```

3. Initialize Terraform:

```bash
terraform init
```

4. Review the deployment plan:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

The deployment will take approximately 20 minutes. Once complete, access the Mario game at the URL shown in the Terraform output.

## Architecture Details

### Networking

- Custom VPC with regional subnets (us-east5, us-central1, us-west4)
- Private GKE clusters with external control plane access
- Cloud NAT for outbound internet connectivity
- Global load balancing via Gateway API

### GKE Clusters

- Three regional clusters across US regions:
  - us-east5 (Virginia)
  - us-central1 (Iowa)
  - us-west4 (Las Vegas)
- Private nodes with VPC-native networking
- Workload identity for secure service accounts
- Regular release channel for stable updates
- Node auto-scaling and auto-repair
- Binary authorization enabled
- Gateway API standard channel

### Mario Application

- Containerized Super Mario browser game
- Deployed across all clusters using Helm
- Horizontal Pod Autoscaling enabled
- Resource limits and requests defined
- Health checks and readiness probes
- Cross-region failover support

## Monitoring

Access cluster resources:

```bash
# Get credentials for a cluster
gcloud container clusters get-credentials [CLUSTER_NAME] --region [REGION]

# View deployments
kubectl get deployments -n mario

# Check pod status
kubectl get pods -n mario

# View Gateway API resources
kubectl get gateway,httproute -n mario
```

## Troubleshooting

### Common Issues

1. Load Balancer Not Ready

```bash
# Check Gateway status
kubectl get gateway -n mario
kubectl describe gateway mario-external-gateway -n mario
```

2. Pods Not Starting

```bash
# Check pod status and events
kubectl get pods -n mario
kubectl describe pods -n mario
```

3. Cross-Region Issues

```bash
# Verify service discovery
kubectl get serviceimport -n mario
kubectl describe serviceexport mario-service -n mario
```

### Logs Collection

```bash
# Collect pod logs
kubectl logs -l app=mario -n mario

# Get cluster events
kubectl get events -n mario
```

## Clean Up

Remove all created resources:

```bash
terraform destroy --auto-approve
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Notes

- Initial deployment takes ~20 minutes
- Load balancer provisioning requires ~5 minutes
- Access Mario at the URL from terraform output
- Resources optimized for demo purposes

## Security Notes

This implementation:

- Has a Public Control Plane (whitelisted IPs, but still Public)
- Uses HTTP (not HTTPS)
- Is intended for development/testing purposes
- Is not suitable for production use

## Support

Create an issue for:

- Bug reports
- Feature requests
- Deployment questions

## Contributors

Special thanks to:

- **Stephen Eden** ([@stephanjeden](https://github.com/stephanjeden)) - For his invaluable assistance with the project, particularly in creating the Helm templates for multi-cluster deployment.

## License

This project is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.
