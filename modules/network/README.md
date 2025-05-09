# GCP Network Terraform Module

This module creates a Google Cloud Platform VPC network with associated resources including subnets, Cloud NAT, Cloud Router, and firewall rules.

## Features

- Creates a custom mode VPC network
- Supports multiple subnet configurations
- Configures Cloud NAT and Cloud Router for internet egress
- Flexible firewall rule management
- Supports global or regional routing modes
- Automatic Cloud Router and NAT gateway creation

## Requirements

- Terraform >= 1.11.0
- Google Provider >= 6.30.0
- Google Project with the following APIs enabled:
  - compute.googleapis.com

## Usage

### Basic Example

```hcl
module "network" {
  source       = "./modules/network"
  project_id   = "my-project"
  network_name = "my-vpc"

  subnets = {
    "subnet-1" = {
      region = "us-central1"
      cidr   = "10.0.0.0/24"
    }
  }
}
```

### Complete Example

```hcl
module "network" {
  source       = "./modules/network"
  project_id   = "my-project"
  network_name = "my-vpc"
  routing_mode = "REGIONAL"

  # Multiple subnet configuration
  subnets = {
    "subnet-us-central" = {
      region = "us-central1"
      cidr   = "10.0.1.0/24"
    }
    "subnet-us-east" = {
      region = "us-east1"
      cidr   = "10.0.2.0/24"
    }
  }

  # Comprehensive firewall rules
  firewall_rules = {
    "allow-internal" = {
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["10.0.0.0/8"]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }, {
        protocol = "udp"
        ports    = ["0-65535"]
      }]
    }
    "allow-ssh" = {
      direction     = "INGRESS"
      source_ranges = ["35.235.240.0/20"]  # IAP range
      target_tags   = ["ssh"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    }
    "allow-health-checks" = {
      direction     = "INGRESS"
      source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]
    }
  }

  # Enable Cloud NAT in multiple regions
  cloud_nat_configs = ["us-central1", "us-east1"]
}
```

## Module Configuration

### Required Variables

- `project_id` - Your GCP project ID
- `network_name` - Name for the VPC network
- `subnets` - At least one subnet configuration

### Optional Variables

- `routing_mode` - Network routing mode ("GLOBAL" or "REGIONAL", defaults to "GLOBAL")
- `firewall_rules` - Map of firewall rule configurations
- `cloud_nat_configs` - Set of regions where Cloud NAT should be enabled

### Subnet Configuration

Each subnet requires:

```hcl
{
  region = string       # GCP region for the subnet
  cidr   = string       # CIDR range for the subnet
}
```

### Firewall Rule Configuration

Each firewall rule supports:

```hcl
{
  direction     = string           # "INGRESS" or "EGRESS"
  priority      = number          # Optional, defaults to 1000
  source_ranges = list(string)    # Optional, source IP ranges
  target_tags   = list(string)    # Optional, instance tags
  allow = list(object({
    protocol = string           # "tcp", "udp", "icmp"
    ports    = list(string)    # Optional, port numbers
  }))
}
```

## Outputs

| Name              | Description                                     |
| ----------------- | ----------------------------------------------- |
| network           | The complete network resource                   |
| network_id        | The unique identifier for the VPC               |
| network_self_link | The URI of the VPC                              |
| subnets           | Map of all created subnet resources             |
| subnet_ids        | Map of subnet names to their unique identifiers |

## Notes

- All subnets are created with Private Google Access enabled by default
- Cloud NAT is configured with automatic IP allocation
- Firewall rules support both tagged and untagged instances

## License

This module is licensed under the GNU General Public License v3.0
