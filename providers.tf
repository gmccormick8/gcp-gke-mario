terraform {
  required_version = "~> 1.11"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.30"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.30"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
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
  host                   = "https://${module.prod-central-cluster.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.prod-central-cluster.master_auth.cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "east"
  host                   = "https://${module.prod-east-cluster.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.prod-east-cluster.master_auth.cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "west"
  host                   = "https://${module.prod-west-cluster.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.prod-west-cluster.master_auth.cluster_ca_certificate)
}

provider "helm" {
  alias = "east"
  kubernetes {
    host                   = "https://${module.prod-east-cluster.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.prod-east-cluster.master_auth.cluster_ca_certificate)
  }
}

provider "helm" {
  alias = "central"
  kubernetes {
    host                   = "https://${module.prod-central-cluster.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.prod-central-cluster.master_auth.cluster_ca_certificate)
  }
}

provider "helm" {
  alias = "west"
  kubernetes {
    host                   = "https://${module.prod-west-cluster.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.prod-west-cluster.master_auth.cluster_ca_certificate)
  }
}
