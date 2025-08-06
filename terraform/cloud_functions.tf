# Cloud Function for Compute Engine alerts
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.gcp_project_id}-cloud-functions"
  location = var.gcp_region
  uniform_bucket_level_access = true
}

# Archive the Cloud Function source code
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/cloud_functions/alerts/compute_engine_on"
  output_path = "${path.module}/compute_engine_alert_function.zip"
}

# Upload the function code to Cloud Storage
resource "google_storage_bucket_object" "function_code" {
  name   = "compute_engine_alert_function-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_zip.output_path
}

# Create the Cloud Function
resource "google_cloudfunctions2_function" "compute_engine_alert" {
  name        = "compute-engine-alert"
  location    = var.gcp_region
  description = "Cloud Function to alert when Compute Engine instances are running too long"

  build_config {
    runtime     = "python311"
    entry_point = "check_instances_and_notify"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_code.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 540
    environment_variables = {
      EMAIL = var.alert_email
      SMTP_PASSWORD = var.smtp_password
      ALERT_THRESHOLD_MINUTES = var.alert_threshold_minutes
      COMPUTE_ZONES = join(",", var.compute_zones)
    }
  }

  event_trigger {
    trigger_region = var.gcp_region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.alert_topic.id
  }
}

# Create Pub/Sub topic for triggering the function
resource "google_pubsub_topic" "alert_topic" {
  name = "compute-engine-alert-topic"
}

# Create Cloud Scheduler job to trigger the function periodically
resource "google_cloud_scheduler_job" "alert_scheduler" {
  name             = "compute-engine-alert-scheduler"
  description      = "Scheduler to check Compute Engine instances every 15 minutes"
  schedule         = "*/15 * * * *"  # Every 15 minutes
  time_zone        = "UTC"
  attempt_deadline = "600s"

  pubsub_target {
    topic_name = google_pubsub_topic.alert_topic.id
    data       = base64encode("check_instances")
  }
}

# IAM permissions for the Cloud Function
resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = google_cloudfunctions2_function.compute_engine_alert.project
  location       = google_cloudfunctions2_function.compute_engine_alert.location
  cloud_function = google_cloudfunctions2_function.compute_engine_alert.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.function_service_account.email}"
}

# Service account for the Cloud Function
resource "google_service_account" "function_service_account" {
  account_id   = "compute-engine-alert-function"
  display_name = "Service Account for Compute Engine Alert Function"
  description  = "Service account used by the Compute Engine alert Cloud Function"
}

# IAM permissions for the service account
resource "google_project_iam_member" "function_compute_viewer" {
  project = var.gcp_project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
}

resource "google_project_iam_member" "function_logging_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
}

resource "google_project_iam_member" "function_pubsub_publisher" {
  project = var.gcp_project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
} 