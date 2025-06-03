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
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
