# Kubernetes Module for Mario Application

This module deploys the Super Mario game on a GKE cluster using Helm. It includes configurations for auto-scaling, resource management, and load balancing.

## Features

- Helm-based deployment
- Horizontal Pod Autoscaling (HPA)
- Load Balancer service type
- Resource limits and requests
- Readiness probes
- Container security context
- Configurable image and replica count

## Prerequisites

- GKE Cluster with Gateway API enabled
- Helm 3.x
- kubectl configured with cluster access
- Required GCP APIs enabled:
  - container.googleapis.com
  - containerregistry.googleapis.com
  - compute.googleapis.com
  - iam.googleapis.com

## Usage

```hcl
module "k8s_mario" {
  source = "./modules/k8s"

  project_id             = "my-project-id"
  cluster_name          = "my-cluster"
  cluster_location      = "us-central1-a"
  cluster_endpoint      = "cluster-endpoint"
  cluster_ca_certificate = "base64-encoded-ca-cert"
  image                 = "sevenajay/mario:latest"
  min_replicas          = 1
  max_replicas          = 5
}
```

## Module Variables

| Name                   | Description                                     | Type   | Default | Required |
| ---------------------- | ----------------------------------------------- | ------ | ------- | :------: |
| project_id             | GCP Project ID                                  | string | -       |   yes    |
| cluster_name           | Name of the GKE cluster                         | string | -       |   yes    |
| cluster_location       | Location of the GKE cluster                     | string | -       |   yes    |
| cluster_endpoint       | Cluster API endpoint                            | string | -       |   yes    |
| cluster_ca_certificate | Cluster CA certificate (base64 encoded)         | string | -       |   yes    |
| image                  | Docker image for Mario (format: repository:tag) | string | -       |   yes    |
| min_replicas           | Minimum number of pod replicas                  | number | 1       |    no    |
| max_replicas           | Maximum number of pod replicas                  | number | 5       |    no    |

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

## Outputs

| Name             | Description                              |
| ---------------- | ---------------------------------------- |
| load_balancer_ip | External IP address of the load balancer |

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
