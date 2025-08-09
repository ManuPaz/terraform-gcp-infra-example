# ========================================
# CLOUD STORAGE CONFIGURATION
# ========================================
# This file contains the Cloud Storage bucket configuration

# Create the Cloud Storage bucket for FMP backup data
resource "google_storage_bucket" "fmp_backup_bucket" {
  name          = var.cloud_storage_bucket_name
  location      = var.gcp_region
  force_destroy = false

  # Storage class configuration
  storage_class = "STANDARD"

 uniform_bucket_level_access = true
 
  # Public access prevention
  public_access_prevention = "enforced"


  # Labels for better organization
  labels = {
    environment = "production"
    purpose     = "fmp-backup"
    managed_by  = "terraform"
  }
}


