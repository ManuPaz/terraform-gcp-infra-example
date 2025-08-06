# ========================================
# MAIN TERRAFORM CONFIGURATION
# ========================================
# This file contains the basic Terraform configuration and provider setup

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
} 