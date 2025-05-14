# Kubernetes Module for Mario Application

## Required GCP APIs

This module requires the following Google Cloud APIs to be enabled in your project:

- `container.googleapis.com` - Google Kubernetes Engine API
- `containerregistry.googleapis.com` - Container Registry API
- `compute.googleapis.com` - Compute Engine API
- `iam.googleapis.com` - Identity and Access Management API

### How to Enable APIs

You can enable these APIs using gcloud:

```bash
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
```

Or include them in your Terraform configuration using the `google_project_service` resource.
