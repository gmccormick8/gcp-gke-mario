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
}

data "google_client_config" "default" {}
data "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.cluster_location
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
}