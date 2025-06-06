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
  }
}
