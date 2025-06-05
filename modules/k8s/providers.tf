terraform {
  required_version = "~> 1.11"

  required_providers {
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version              = "~> 2.30"
      configuration_aliases = [kubernetes]
    }
    helm = {
      source                = "hashicorp/helm"
      version              = "~> 2.10"
      configuration_aliases = [helm]
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
  }
}
