# Kubernetes Module for Multi-Cluster Mario Deployment

This module deploys the Super Mario browser game across GKE clusters using Gateway API for global load balancing and multi-cluster service discovery.

## Features

### Core Functionality

- Global load balancing with Gateway API
- Multi-cluster service discovery and failover
- Automated horizontal pod scaling
- Container health monitoring
- Resource optimization

### Security

- Non-root container execution
- No privilege escalation
- Resource quotas and limits
- Network policy support
- Secure service discovery

### Operations

- Rolling updates
- Health checks and readiness probes
- Automated scaling policies
- Resource monitoring
- Cross-cluster traffic management

## Usage

Basic deployment:

```hcl
module "k8s_mario" {
  source = "./modules/k8s"

  cluster_name     = "central-cluster"
  cluster_endpoint = module.gke.cluster_endpoint
  cluster_ca_cert  = module.gke.cluster_ca_certificate
  config_cluster   = true

  # Container configuration
  image         = "sevenajay/mario:latest"
  min_replicas  = 1
  max_replicas  = 5
}
```

## Requirements

### Infrastructure

- GKE cluster with Gateway API enabled
- Multi-cluster service discovery enabled
- Fleet registration complete

### APIs

- container.googleapis.com
- gkehub.googleapis.com
- multiclusterservicediscovery.googleapis.com
- multiclusteringress.googleapis.com

### Software Versions

- Terraform ~> 1.11
- Kubernetes Provider ~> 2.30
- Helm Provider ~> 2.10

## Resource Specifications

### Compute Resources

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
  minReplicas: 1
  maxReplicas: 5
  cpuUtilization: 75
  memoryUtilization: 75
  scaleUpStabilization: 60s
  scaleDownStabilization: 300s
```

## Operational Commands

### Health Monitoring

```bash
# Gateway status
kubectl get gateway -n mario

# Service health
kubectl get serviceimport -n mario
kubectl get pods -n mario

# Scaling status
kubectl get hpa -n mario
```

### Troubleshooting

1. Gateway Configuration

```bash
# Check Gateway status
kubectl describe gateway mario-external-gateway -n mario

# View Gateway events
kubectl get events -n mario --field-selector involvedObject.kind=Gateway
```

2. Service Discovery

```bash
# Verify service export
kubectl describe serviceexport mario-service -n mario

# Check service import status
kubectl get serviceimport mario-service -n mario -o yaml
```

3. Application Health

```bash
# Container logs
kubectl logs -l app=mario -n mario

# Pod events
kubectl get events -n mario --field-selector involvedObject.kind=Pod
```

## Module Configuration

### Required Variables

| Name             | Description            | Type   |
| ---------------- | ---------------------- | ------ |
| cluster_name     | GKE cluster name       | string |
| cluster_endpoint | Cluster API endpoint   | string |
| cluster_ca_cert  | Cluster CA certificate | string |
| config_cluster   | Enable Gateway config  | bool   |
| image            | Container image        | string |

### Optional Variables

| Name         | Description          | Type   | Default |
| ------------ | -------------------- | ------ | ------- |
| min_replicas | Minimum pod replicas | number | 1       |
| max_replicas | Maximum pod replicas | number | 5       |

## Implementation Notes

### Deployment Process

1. Creates namespace
2. Deploys Gateway API resources
3. Configures service discovery
4. Launches application pods
5. Establishes health checks
6. Enables autoscaling

### Known Limitations

- Gateway API must be enabled on all clusters
- Initial load balancer provisioning takes ~5 minutes
- HTTP traffic only
- Clusters must be in the same fleet

## Support

For issues and feature requests, please:

1. Check the troubleshooting guide above
2. Review pod and Gateway events
3. Create a detailed GitHub issue

## License

This module is licensed under the GNU General Public License v3.0
