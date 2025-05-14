# gcp-gke-mario

A GKE deployment of Super Mario in the browser.

## Prerequisites

### Version Requirements

- Google Cloud SDK
- Terraform ~> 1.11.0
- kubectl

The tilde (~>) operator allows only the rightmost version component to increment. For example, `~> 1.11` allows installing versions 1.11.0 up to but not including 1.12.0.

## Setup

1. Initialize and apply the Terraform configuration:

```bash
# Initialize Terraform
./setup.sh
```

2. Deploy the application:

```bash
# Make the deployment script executable
chmod +x deploy.sh

# Deploy the application
./deploy.sh
```

3. Access the application using the external IP provided by the deploy script.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```
