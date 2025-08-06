locals {
  investpy_tables = {
    "investpy_news_economy"              = "economy"
    "investpy_news_company-news"         = "company-news"
    "investpy_news_stock-market-news"    = "stock-market-news"
    "investpy_news_insider-trading-news" = "insider-trading-news"
    "investpy_news_earnings"             = "earnings"
    "investpy_news_investment-ideas"     = "investment-ideas"
    "investpy_news_transcripts"          = "transcripts"
    "investpy_news_analyst-ratings"      = "analyst-ratings"
  }

  top_k_articles_tables = {
    "top_k_articles_economy"              = "economy"
    "top_k_articles_company-news"         = "company-news"
    "top_k_articles_stock-market-news"    = "stock-market-news"
    "top_k_articles_insider-trading-news" = "insider-trading-news"
    "top_k_articles_earnings"             = "earnings"
    "top_k_articles_investment-ideas"     = "investment-ideas"
    "top_k_articles_transcripts"          = "transcripts"
    "top_k_articles_analyst-ratings"      = "analyst-ratings"
  }
}

resource "google_bigquery_table" "investpy_news" {
  for_each  = local.investpy_tables

  dataset_id = google_bigquery_dataset.main_dataset.dataset_id
  table_id   = each.key
  project    = var.gcp_project_id

  schema = file("${path.module}/schemas/investpy_news_economy_schema.json")

  external_data_configuration {
    source_uris = ["gs://${var.bigquery_data_bucket}/investpy/news/${each.value}/*"]
    source_format = "PARQUET"
    hive_partitioning_options {
      mode = "AUTO"
      source_uri_prefix = "gs://${var.bigquery_data_bucket}/investpy/news/${each.value}"
      require_partition_filter = false
    }
    autodetect = false
  }
}

resource "google_bigquery_table" "top_k_articles" {
  for_each  = local.top_k_articles_tables

  dataset_id = google_bigquery_dataset.main_dataset.dataset_id
  table_id   = each.key
  project    = var.gcp_project_id
  deletion_protection = false

  schema = file("${path.module}/schemas/top_k_articles_schema.json")

  external_data_configuration {
    source_uris = ["gs://${var.bigquery_unstructured_bucket}/top_k_articles/investpy/news/${each.value}/daily/*"]
    source_format = "NEWLINE_DELIMITED_JSON"
    hive_partitioning_options {
      mode = "AUTO"
      source_uri_prefix = "gs://${var.bigquery_unstructured_bucket}/top_k_articles/investpy/news/${each.value}/daily"
      require_partition_filter = false
    }
    autodetect = false
  }
}

resource "google_bigquery_table" "daily_update_info_quotes_forex" {
  dataset_id = google_bigquery_dataset.main_dataset.dataset_id
  table_id   = "daily_update_info_quotes_forex"
  project    = var.gcp_project_id

  external_data_configuration {
    source_uris = ["gs://${var.bigquery_data_bucket}/daily_update_info_quotes_forex/*"]
    source_format = "PARQUET"
    hive_partitioning_options {
      mode = "AUTO"
      source_uri_prefix = "gs://${var.bigquery_data_bucket}/daily_update_info_quotes_forex"
      require_partition_filter = false
    }
    autodetect = true
  }
}

# Profiles DataFrame Table
resource "google_bigquery_table" "profiles_df" {
  dataset_id = google_bigquery_dataset.main_dataset.dataset_id
  table_id   = "profiles_df"
  project    = var.gcp_project_id
  deletion_protection = false

  external_data_configuration {
    source_uris = ["gs://${var.bigquery_data_bucket}-processed/profiles/front/profiles_front_df.csv"]
    source_format = "CSV"
    autodetect = true
    max_bad_records = 100
  }
}

# Symbols Mapping Table
resource "google_bigquery_table" "symbols_mapping" {
  dataset_id = google_bigquery_dataset.main_dataset.dataset_id
  table_id   = "symbols_mapping"
  project    = var.gcp_project_id
  deletion_protection = false

  external_data_configuration {
    source_uris = ["gs://${var.bigquery_data_bucket}-processed/symbols_mapping/symbols_mapping_df.csv"]
    source_format = "CSV"
    autodetect = true
    max_bad_records = 100
  }
}

# Earnings Calendar Table
resource "google_bigquery_table" "earnings_calendar" {
  dataset_id = google_bigquery_dataset.main_dataset.dataset_id
  table_id   = "earnings_calendar"
  project    = var.gcp_project_id
  deletion_protection = false

  schema = file("${path.module}/schemas/earnings_calendar_schema.json")

  external_data_configuration {
    source_uris = ["gs://${var.bigquery_data_bucket}/stocks_calendar_earning_calendar-jsonl/*"]
    source_format = "NEWLINE_DELIMITED_JSON"
    autodetect = false
  }
} 