# Kubernetes Multi-Cluster Module for Mario Application

This module deploys the Super Mario game across multiple GKE clusters using Gateway API for global load balancing.

## Features

- Multi-cluster deployment with Gateway API
- Global load balancing across regions
- Automated failover and traffic distribution
- Helm-based deployment in each cluster
- Horizontal Pod Autoscaling (HPA)
- Resource limits and requests

## Prerequisites

- Multiple GKE Clusters with Gateway API enabled
- Fleet registration enabled (requires gkehub.googleapis.com)
- Helm 3.x
- kubectl configured with cluster access
- Compute Engine API enabled (compute.googleapis.com)

## Usage

```hcl
module "k8s_mario" {
  source = "./modules/k8s"

  project_id = "my-project-id"
  clusters = {
    east = {
      name     = "east-cluster"
      location = "us-east5-c"
      endpoint = "cluster-endpoint"
      ca_cert  = "base64-encoded-ca-cert"
    }
    central = {
      name     = "central-cluster"
      location = "us-central1-c"
      endpoint = "cluster-endpoint"
      ca_cert  = "base64-encoded-ca-cert"
    }
    west = {
      name     = "west-cluster"
      location = "us-west4-c"
      endpoint = "cluster-endpoint"
      ca_cert  = "base64-encoded-ca-cert"
    }
  }
  image        = "sevenajay/mario:latest"
  min_replicas = 1
  max_replicas = 5
}
```

## Module Variables

| Name         | Description                                     | Type        | Required |
| ------------ | ----------------------------------------------- | ----------- | :------: |
| project_id   | GCP Project ID                                  | string      |   yes    |
| clusters     | Map of cluster configurations                   | map(object) |   yes    |
| image        | Docker image for Mario (format: repository:tag) | string      |   yes    |
| min_replicas | Minimum number of pod replicas per cluster      | number      |    no    |
| max_replicas | Maximum number of pod replicas per cluster      | number      |    no    |

## Helm Chart Configuration

### Default Resource Limits

```yaml
resources:
  limits:
    cpu: 500m
    memory: 1000Mi
    ephemeral-storage: 4Gi
  requests:
    cpu: 250m
    memory: 512Mi
    ephemeral-storage: 2Gi
```

### Autoscaling Configuration

```yaml
autoscaling:
  enabled: true
  cpuUtilization: 75
  memoryUtilization: 75
  scaleUpStabilization: 60
  scaleDownStabilization: 300
```

## Gateway API Configuration

The module configures:

- GatewayClass for global load balancing
- Gateway for HTTP traffic
- HTTPRoute for traffic distribution across clusters
- Automatic health checking and failover
- Intelligent traffic routing based on user location

## Outputs

| Name             | Description                                     |
| ---------------- | ----------------------------------------------- |
| load_balancer_ip | Global IP address for accessing the application |

## Security Features

- Non-privileged container execution
- No privilege escalation allowed
- Resource limits enforced
- Readiness probe for health checking

## Troubleshooting

1. If pods fail to start, check resource quotas:

   ```bash
   kubectl describe pod -n mario
   ```

2. For load balancer issues:

   ```bash
   kubectl get svc -n mario
   ```

3. To check autoscaling status:
   ```bash
   kubectl get hpa -n mario
   ```

## License

This module is licensed under the GNU General Public License v3.0
