terraform {
  required_version = "~> 1.11"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.30"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "<= 2.36.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}
