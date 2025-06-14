#!/bin/bash
# This script sets up the environment for Cloud Shell and applies the Terraform script.
#usage: bash setup.sh [-y] or ./setup.sh [-y]

# Exit immediately if a command exits with a non-zero status. 
set -e

# Parse command line arguments
auto_approve=false

# Check if there are any arguments
if [ $# -gt 1 ]; then
    echo "Invalid option. USAGE: bash setup.sh [-y] or ./setup.sh [-y]" 1>&2
    exit 1
fi

if [ $# -eq 1 ]; then
    if [ "$1" != "-y" ]; then
        echo "Invalid option. USAGE: bash setup.sh [-y] or ./setup.sh [-y]" 1>&2
        exit 1
    fi
    auto_approve=true
fi

echo "Setting up the environment..."

# Check and set PROJECT_ID
if [ -n "$DEVSHELL_PROJECT_ID" ]; then
  export PROJECT_ID="$DEVSHELL_PROJECT_ID"
  echo "Using Cloud Shell Project ID: '$PROJECT_ID'"
elif [ -z "$PROJECT_ID" ]; then
  echo "Error: PROJECT_ID is not set. Please set the PROJECT_ID environment variable or run from Google Cloud Console."
  exit 1
fi

echo "Using Project ID: '$PROJECT_ID'"

echo -e 'project_id = "'"$PROJECT_ID"'"\npublic_ip = "'"$(curl -s ifconfig.me)"'"' > terraform.tfvars

api_array=(
  "compute.googleapis.com"
  "cloudresourcemanager.googleapis.com"
  "container.googleapis.com"
  "iam.googleapis.com"
  "gkehub.googleapis.com"
  "trafficdirector.googleapis.com"
  "multiclusterservicediscovery.googleapis.com"
  "multiclusteringress.googleapis.com"
  "anthos.googleapis.com"
)

for api in "${api_array[@]}";
do
  echo "Enabling API: $api"
  gcloud services enable "$api" --project="$DEVSHELL_PROJECT_ID"
done

# Check the Terraform version and updates if needed. Based on jacouh's script https://stackoverflow.com/a/66879840
version=$(terraform -v | grep -Eo -m 1 '[0-9]+\.[0-9]+\.[0-9]+')
expected_version=1.11.0

IFS="." read -ra xarr <<< "$version"
IFS="." read -ra yarr <<< "$expected_version"

current=true
for i in "${!xarr[@]}"; do
 if [ "${xarr[i]}" -ge "${yarr[i]}" ]; then
    current=true
  elif [ "${xarr[i]}" -lt "${yarr[i]}" ]; then
    current=false
    break
  fi
done

if [[ $current == false ]]; then
  if [[ "$auto_approve" == true ]]; then
    update_response="y"
  else
    read -rp "Terraform version is less than 1.11.0. Do you want to update it? (y/n) " update_response
  fi
  if [[ "$update_response" != "y" ]]; then
    echo "Exiting without updating Terraform."
    exit 1
  else
    echo "Updating Terraform..."
    if ! {
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
    }; then
      echo "Error during Terraform update. Exiting..."
      exit 1
    fi
    echo "Terraform updated successfully."
  fi
fi

# Many thanks to Praneeth Bilakanti https://praneethreddybilakanti.medium.com/terraform-with-shell-scripts-e6007f975a90 for this bit! :)
echo "Running Terraform init..."

if ! terraform init; then
  echo "Error during init. Exiting..."
  exit 1
fi

echo "Running Terraform plan..."

if ! terraform plan; then
  echo "Error during plan. Exiting..."
  exit 1
fi

if [[ "$auto_approve" == true ]]; then
  response="y"
else
  read -rp "Do you want to apply the changes? (y/n) " response
fi
if [[ "$response" == "y" ]]; then
  if ! terraform apply --auto-approve; then
    echo "Error during apply. Exiting..."
    exit 1
  fi
  echo "Terraform apply completed successfully."
  echo "Mario game will be available at: $(terraform output -raw mario_gateway_url)"
  echo "Note: It may take up to 10 minutes for the load balancer to be fully provisioned."
else
  echo "Apply canceled."
fi
