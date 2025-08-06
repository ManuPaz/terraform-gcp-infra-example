resource "google_bigquery_dataset" "main_dataset" {
  dataset_id                  = var.bigquery_dataset_id
  project                     = var.gcp_project_id
  location                    = var.bq_location
  delete_contents_on_destroy  = false
   lifecycle {
    prevent_destroy = true
  }
} 