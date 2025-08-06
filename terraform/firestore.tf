# Firestore Database Configuration

# Create Firestore Database
resource "google_firestore_database" "default" {
  name        = "user-documents"
  location_id = var.gcp_region
  type        = "FIRESTORE_NATIVE"
  project     = var.gcp_project_id
}

# Firestore Security Rules - BLOCK ALL ACCESS
resource "google_firestore_document" "firestore_rules" {
  project     = var.gcp_project_id
  collection  = "firestore"
  document_id = "rules"
  fields      = jsonencode({
    "rules" = {
      stringValue = <<-EOT
        rules_version = '2';
        service cloud.firestore {
          match /databases/{database}/documents {
            match /{document=**} {
              allow read, write: if false;
            }
          }
        }
      EOT
    }
  })
} 