# GCP GKE Mario

Deploy Super Mario in the browser using GKE with a global multi-cluster infrastructure. This project demonstrates modern cloud-native patterns including multi-cluster load balancing, Gateway API, and automated scaling.

## Features

- **Multi-Regional Infrastructure**

  - VPC network with subnets across US regions
  - Private GKE clusters with managed control planes
  - Cloud NAT for secure internet egress
  - Regional failover and redundancy

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

## Quick Start

1. Clone this repository:

```bash
git clone https://github.com/gabrielmccormick/gcp-gke-mario.git
cd gcp-gke-mario
```

2. Run the setup script:

```bash
bash setup.sh
```

The setup process:

- Enables required GCP APIs
- Verifies/updates Terraform version
- Creates terraform.tfvars with your project ID
- Initializes and applies Terraform configuration

## Architecture Details

### Networking

- Custom VPC with regional subnets (us-east5, us-central1, us-west4)
- Private GKE clusters with external control plane access
- Cloud NAT for outbound internet connectivity
- Global load balancing via Gateway API

### GKE Clusters

- Three regional clusters for high availability
- Private nodes with VPC-native networking
- Workload identity for secure service accounts
- Regular release channel for stable updates
- Node auto-scaling and auto-repair

### Mario Application

- Containerized Super Mario browser game
- Deployed across all clusters using Helm
- Horizontal Pod Autoscaling enabled
- Resource limits and requests defined
- Health checks and readiness probes

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

## Support

Create an issue for:

- Bug reports
- Feature requests
- Deployment questions

## License

This project is licensed under the GNU General Public License v3.0
