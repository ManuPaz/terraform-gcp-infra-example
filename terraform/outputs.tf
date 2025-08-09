# Logs Exclusion Outputs
output "cloud_functions_exclusions" {
  description = "Created Cloud Functions log exclusions"
  value       = google_logging_project_exclusion.cloud_functions_exclusion
}

output "cloud_run_exclusions" {
  description = "Created Cloud Run log exclusions"
  value       = google_logging_project_exclusion.cloud_run_exclusion
}

output "compute_engine_exclusions" {
  description = "Created Compute Engine log exclusions"
  value       = google_logging_project_exclusion.compute_engine_exclusion
}

output "cloud_run_jobs_exclusions" {
  description = "Created Cloud Run Jobs log exclusions"
  value       = google_logging_project_exclusion.cloud_run_jobs_exclusion
}

output "cloud_scheduler_exclusions" {
  description = "Created Cloud Scheduler log exclusions"
  value       = google_logging_project_exclusion.cloud_scheduler_exclusion
}

output "pubsub_exclusions" {
  description = "Created Pub/Sub log exclusions"
  value       = google_logging_project_exclusion.pubsub_exclusion
}

# Cloud Function Outputs
output "cloud_function_url" {
  description = "URL of the deployed Cloud Function"
  value       = google_cloudfunctions2_function.compute_engine_alert.url
}

output "cloud_function_name" {
  description = "Name of the deployed Cloud Function"
  value       = google_cloudfunctions2_function.compute_engine_alert.name
}

output "function_service_account_email" {
  description = "Email of the service account used by the Cloud Function"
  value       = google_service_account.function_service_account.email
}

output "alert_topic_name" {
  description = "Name of the Pub/Sub topic for alerts"
  value       = google_pubsub_topic.alert_topic.name
}

output "scheduler_job_name" {
  description = "Name of the Cloud Scheduler job"
  value       = google_cloud_scheduler_job.alert_scheduler.name
}

output "function_bucket_name" {
  description = "Name of the Cloud Storage bucket for function code"
  value       = google_storage_bucket.function_bucket.name
}

output "total_exclusions_created" {
  description = "Total number of log exclusions created"
  value = (
    length(google_logging_project_exclusion.cloud_functions_exclusion) +
    length(google_logging_project_exclusion.cloud_run_exclusion) +
    length(google_logging_project_exclusion.compute_engine_exclusion) +
    length(google_logging_project_exclusion.cloud_run_jobs_exclusion) +
    length(google_logging_project_exclusion.cloud_scheduler_exclusion) +
    length(google_logging_project_exclusion.pubsub_exclusion)
  )
}

# Firestore Outputs
output "firestore_database_name" {
  description = "Name of the Firestore database"
  value       = google_firestore_database.default.name
}

output "firestore_database_location" {
  description = "Location of the Firestore database"
  value       = google_firestore_database.default.location_id
}

output "firestore_database_type" {
  description = "Type of the Firestore database"
  value       = google_firestore_database.default.type
}

output "firestore_collections" {
  description = "Available Firestore collections"
  value = [
    "users",
    "documents",
    "prompts"
  ]
} 

# Cloud Storage Outputs
output "cloud_storage_bucket_name" {
  description = "Name of the Cloud Storage bucket for FMP backup data"
  value       = google_storage_bucket.fmp_backup_bucket.name
}

output "cloud_storage_bucket_location" {
  description = "Location of the Cloud Storage bucket"
  value       = google_storage_bucket.fmp_backup_bucket.location
}

output "cloud_storage_bucket_url" {
  description = "URL of the Cloud Storage bucket"
  value       = "gs://${google_storage_bucket.fmp_backup_bucket.name}"
} 

