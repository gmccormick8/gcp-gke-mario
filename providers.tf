terraform {
  required_version = "~> 1.11.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.30.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "google" {
  project = var.project_id
}