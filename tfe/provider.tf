terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.15.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.5.3"
    }
  }
}

provider "google" {
  # Configuration options
  credentials = file("${path.module}/../key.json")
  project     = data.terraform_remote_state.infra.outputs.gcp_project
  region      = data.terraform_remote_state.infra.outputs.gcp_region
}

provider "google-beta" {
  credentials = file("${path.module}/../key.json")
  project     = data.terraform_remote_state.infra.outputs.gcp_project
  region      = data.terraform_remote_state.infra.outputs.gcp_region
}

provider "acme" {
  # server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}


data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "${path.module}/../infra/terraform.tfstate"
  }
}


data "google_client_config" "provider" {}

# data "google_container_cluster" "my_cluster" {
#   name     = data.terraform_remote_state.infra.outputs.cluster-name
#   location = data.terraform_remote_state.infra.outputs.gcp_region
# }

provider "kubernetes" {
  config_path = "/Users/patrickmunne/git/tfe_fdo_gcp_openshift/gcp/auth/kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "/Users/patrickmunne/git/tfe_fdo_gcp_openshift/gcp/auth/kubeconfig"
  }
}