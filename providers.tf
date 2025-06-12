terraform {
  required_version = "~> 1.11"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.36"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.36"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

data "google_client_config" "default" {}

provider "kubernetes" {
  alias                  = "central"
  host                   = "https://${module.gke_clusters["central"].cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_clusters["central"].master_auth.cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "east"
  host                   = "https://${module.gke_clusters["east"].cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_clusters["east"].master_auth.cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "west"
  host                   = "https://${module.gke_clusters["west"].cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_clusters["west"].master_auth.cluster_ca_certificate)
}

provider "helm" {
  alias = "east"
  kubernetes {
    host                   = "https://${module.gke_clusters["east"].cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_clusters["east"].master_auth.cluster_ca_certificate)
  }
}

provider "helm" {
  alias = "central"
  kubernetes {
    host                   = "https://${module.gke_clusters["central"].cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_clusters["central"].master_auth.cluster_ca_certificate)
  }
}

provider "helm" {
  alias = "west"
  kubernetes {
    host                   = "https://${module.gke_clusters["west"].cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_clusters["west"].master_auth.cluster_ca_certificate)
  }
}
