# GCP Project Configuration
variable "gcp_project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "gcp_region" {
  description = "The GCP region for resources"
  type        = string
  default     = "europe-west1"
}

variable "gcp_zone" {
  description = "The GCP zone for resources"
  type        = string
  default     = "europe-west1-b"
}

# Logs Exclusion Configuration
variable "cloud_functions_names_exclusion" {
  description = "List of Cloud Function names to exclude from logs"
  type        = list(string)
  default     = []
}

variable "cloud_run_names_exclusion" {
  description = "List of Cloud Run service names to exclude from logs"
  type        = list(string)
  default     = []
}

variable "compute_engine_names_exclusion" {
  description = "List of Compute Engine instance names to exclude from logs"
  type        = list(string)
  default     = []
}

variable "cloud_run_jobs_names_exclusion" {
  description = "List of Cloud Run job names to exclude from logs"
  type        = list(string)
  default     = []
}

variable "cloud_scheduler_names_exclusion" {
  description = "List of Cloud Scheduler job names to exclude from logs"
  type        = list(string)
  default     = []
}

variable "pubsub_subscription_names_exclusion" {
  description = "List of Pub/Sub subscription names to exclude from logs"
  type        = list(string)
  default     = []
}

# Cloud Function Alert Configuration
variable "alert_email" {
  description = "Email address to send alerts to"
  type        = string
}

variable "smtp_password" {
  description = "SMTP password for sending email alerts"
  type        = string
  sensitive   = true
}

variable "alert_threshold_minutes" {
  description = "Threshold in minutes for Compute Engine instance uptime alerts"
  type        = number
  default     = 30
}

variable "alert_schedule" {
  description = "Cron schedule for the alert function (default: every 15 minutes)"
  type        = string
  default     = "*/15 * * * *"
}

variable "compute_zones" {
  description = "List of GCP zones to monitor for Compute Engine instances"
  type        = list(string)
  default     = ["europe-west1-b", "europe-west1-c"]
}

variable "bq_location" {
  description = "BigQuery location (e.g. EU, US)"
  type        = string
  default     = "EU"
}

# BigQuery Configuration
variable "bigquery_dataset_id" {
  description = "The ID of the BigQuery dataset"
  type        = string
}

variable "bigquery_data_bucket" {
  description = "The GCS bucket containing BigQuery external table data"
  type        = string
}

variable "bigquery_unstructured_bucket" {
  description = "The GCS bucket containing unstructured BigQuery external table data"
  type        = string
} 