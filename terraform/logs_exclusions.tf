# ========================================
# LOGS EXCLUSIONS CONFIGURATION
# ========================================
# This file handles automatic log exclusions for GCP resources
# to optimize costs and reduce log noise

# Create logs exclusion for Cloud Functions
resource "google_logging_project_exclusion" "cloud_functions_exclusion" {
  for_each = toset(var.cloud_functions_names_exclusion)
  
  name        = "exclude-${each.value}-logs"
  description = "Automatically exclude logs for Cloud Function: ${each.value}"
  filter      = "resource.type=\"cloud_function\" AND resource.labels.function_name=\"${each.value}\""
  disabled    = false
}

# Create logs exclusion for Cloud Run services
resource "google_logging_project_exclusion" "cloud_run_exclusion" {
  for_each = toset(var.cloud_run_names_exclusion)
  
  name        = "exclude-${each.value}-logs"
  description = "Automatically exclude logs for Cloud Run service: ${each.value}"
  filter      = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${each.value}\""
  disabled    = false
}

# Create logs exclusion for Compute Engine instances
resource "google_logging_project_exclusion" "compute_engine_exclusion" {
  for_each = toset(var.compute_engine_names_exclusion)
  
  name        = "exclude-${each.value}-logs"
  description = "Automatically exclude logs for Compute Engine instance: ${each.value}"
  filter      = "resource.type=\"gce_instance\" AND resource.labels.instance_name=\"${each.value}\""
  disabled    = false
}

# Create logs exclusion for Cloud Run jobs
resource "google_logging_project_exclusion" "cloud_run_jobs_exclusion" {
  for_each = toset(var.cloud_run_jobs_names_exclusion)
  
  name        = "exclude-${each.value}-logs"
  description = "Automatically exclude logs for Cloud Run job: ${each.value}"
  filter      = "resource.type=\"cloud_run_job\" AND resource.labels.job_name=\"${each.value}\""
  disabled    = false
}

# Create logs exclusion for Cloud Scheduler jobs
resource "google_logging_project_exclusion" "cloud_scheduler_exclusion" {
  for_each = toset(var.cloud_scheduler_names_exclusion)
  
  name        = "exclude-${each.value}-logs"
  description = "Automatically exclude logs for Cloud Scheduler job: ${each.value}"
  filter      = "resource.type=\"cloud_scheduler_job\" AND resource.labels.job_id=\"${each.value}\""
  disabled    = false
}

# Create logs exclusion for Pub/Sub subscriptions
resource "google_logging_project_exclusion" "pubsub_exclusion" {
  for_each = toset(var.pubsub_subscription_names_exclusion)
  
  name        = "exclude-${each.value}-logs"
  description = "Automatically exclude logs for Pub/Sub subscription: ${each.value}"
  filter      = "resource.type=\"pubsub_subscription\" AND resource.labels.subscription_id=\"${each.value}\""
  disabled    = false
} 