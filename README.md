# GCP Infrastructure with Terraform

This repository contains a comprehensive example of Google Cloud Platform (GCP) infrastructure deployment using Terraform. It demonstrates best practices for managing various GCP services including BigQuery, Firestore, Cloud Functions, and logging configurations.

## 🚀 Features

### BigQuery Configuration
- **Dataset Management**: Creates and configures BigQuery datasets with proper lifecycle policies
- **External Tables**: Sets up external tables connecting to Google Cloud Storage
- **Schema Management**: Includes predefined schemas for various data types
- **Data Sources**: Supports multiple data formats (Parquet, JSON, CSV)

### Cloud Storage
- **Data Storage**: Configures Google Cloud Storage buckets for structured and unstructured data

### Firestore Database
- **NoSQL Database**: Configures Firestore for document-based data storage
- **Security Rules**: Implements proper access controls and security policies (initially it doesn't allow reading or writing)

### Logging and Monitoring
- **Log Exclusions**: Configurable log exclusion rules for various GCP services
- **Resource Filtering**: Exclude specific resources from logging to reduce noise
- **Cost Optimization**: Minimize logging costs by filtering unnecessary data

### Cloud Functions
- **Instance Monitoring**: Automatically checks the status of all Compute Engine instances in the project
- **Uptime Alerts**: Sends email notifications when instances have been running longer than a configured threshold
- **Email Notifications**: SMTP-based alert system for instance uptime monitoring
- **Configurable Thresholds**: Customizable alert thresholds and schedules
- **Scheduled Execution**: Cron-based scheduling for regular monitoring

## 📁 Project Structure

```
├── terraform/
│   ├── main.tf                    # Main Terraform configuration
│   ├── variables.tf               # Variable definitions
│   ├── outputs.tf                 # Output values
│   ├── bigquery_dataset.tf        # BigQuery dataset configuration
│   ├── bigquery_external_tables.tf # External tables setup
│   ├── cloud_storage.tf           # Cloud Storage bucket configuration
│   ├── firestore.tf               # Firestore database configuration
│   ├── cloud_functions.tf         # Cloud Functions deployment
│   ├── logs_exclusions.tf         # Log exclusion rules
│   ├── schemas/                   # BigQuery schema definitions
│   └── terraform.tfvars.example   # Example configuration file
├── src/
│   └── cloud_functions/           # Cloud Function source code
├── tests/                         # Test files
│   ├── pytest.ini                # Pytest configuration
│   ├── run_tests.py              # Test runner script
│   ├── test_cloud_functions.py   # Cloud Function tests
│   └── conftest.py               # Test configuration
└── README.md                      # This file
```

## 🛠️ Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.0)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Poetry](https://python-poetry.org/docs/#installation) (for local Cloud Function testing)
- GCP Project with billing enabled
- Appropriate IAM permissions

## ⚙️ Configuration

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd infraestructure
   ```

2. **Configure your GCP project**:
   ```bash
   gcloud auth application-default login
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Set up configuration**:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

4. **Edit configuration**:
   Open `terraform.tfvars` and configure:
   - `gcp_project_id`: Your GCP project ID
   - `alert_email`: Email for receiving alerts
   - `smtp_password`: Gmail app password for SMTP
   - `bigquery_dataset_id`: Your BigQuery dataset ID
   - `bigquery_data_bucket`: Your GCS bucket name for structured data
   - `bigquery_unstructured_bucket`: Your GCS bucket name for unstructured data
   - Other variables as needed

## 🚀 Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## 📊 BigQuery Tables

The infrastructure creates several external tables:

- **InvestPy News Tables**: Financial news data from various categories
- **Top K Articles**: Curated top articles with relevance scoring
- **Daily Update Info**: Forex and quotes data
- **Profiles DataFrame**: Company profile information
- **Symbols Mapping**: Symbol mapping data
- **Earnings Calendar**: Earnings calendar information

## 🗄️ Cloud Storage

The infrastructure configures Google Cloud Storage buckets to serve as the data storage backend:

### Bucket Configuration
- **Storage Class**: Standard storage class for good performance and cost-effectiveness
- **Access Control**: Uniform bucket-level access control for simplified permissions management
- **Regional Storage**: Buckets are configured in the same region as your GCP project for optimal performance

## 🔥 Firestore Database

The infrastructure sets up a Firestore database with the following structure:

### Security Features
- **Secure Rules**: Custom security rules with user-based access control (initially it doesn't allow reading or writing)

### Database Configuration
- **Type**: Native Firestore
- **Location**: Same as project region

## 🔔 Alert System

The Cloud Function provides automated monitoring for Compute Engine instances:

### How it works:
- **Scans all instances**: Checks the status of every Compute Engine instance in your project
- **Uptime detection**: Identifies instances that have been running longer than the configured threshold
- **Email alerts**: Sends notifications via SMTP when instances exceed the time limit
- **Scheduled monitoring**: Runs automatically every 15 minutes (configurable)

### Alert triggers:
- Instances running longer than the configured threshold (default: 30 minutes)
- Scheduled checks run every 15 minutes (configurable)
- Email notifications sent via SMTP to specified recipients

### Alert Configuration
- `alert_threshold_minutes`: Minutes before alerting (default: 30)
- `alert_schedule`: Cron schedule for checks (default: every 15 minutes)
- `compute_zones`: Zones to monitor (default: europe-west1-b, europe-west1-c)

## 📝 Log Exclusions

Configure log exclusions for various GCP services to reduce logging costs:

- **Cloud Functions**: Exclude specific function names
- **Cloud Run**: Exclude specific service names
- **Compute Engine**: Exclude specific instance names
- **Cloud Scheduler**: Exclude specific job names
- **Pub/Sub**: Exclude specific subscription names

## 🔧 Customization

### Adding New BigQuery Tables
1. Add table configuration to `bigquery_external_tables.tf`
2. Define schema in `schemas/` directory
3. Update variables if needed

### Modifying Firestore Configuration
1. Update database settings in `firestore.tf`
2. Modify security rules as needed
3. Add new collections in your application code
4. Update indexes for performance optimization

### Modifying Alert Rules
1. Edit `alert_threshold_minutes` in configuration
2. Modify `alert_schedule` for different check frequencies
3. Update `compute_zones` to monitor different zones

### Adding Log Exclusions
1. Add resource names to exclusion lists in configuration
2. Apply changes with `terraform apply`

## 🧪 Testing

The testing suite verifies that the Cloud Function works correctly:

### Local Development Setup

1. **Install Poetry dependencies**:
   ```bash
   poetry install
   ```

2. **Test Cloud Functions locally**:
   ```bash
   poetry run python src/cloud_functions/alerts/compute_engine_on/main.py
   ```

### Test Types
- **Mock Tests**: Tests the Cloud Function with mocked Compute Engine instances (fast, no real infrastructure)
- **Real Integration Tests**: Tests the Cloud Function against your actual GCP project and real Compute Engine instances

### Running Tests

```bash
# Run all tests
cd tests
python run_tests.py

# Run specific test types
python run_tests.py --type mock      # Mock tests (fast)
python run_tests.py --type real      # Real integration tests
python run_tests.py --type cloud-functions  # All Cloud Function tests

# Run with coverage
python run_tests.py --coverage

# Run with verbose output
python run_tests.py --verbose
```

### Test Structure
- **Mock Tests**: Fast tests with mocked Compute Engine instances (`--type mock`)
- **Real Integration Tests**: Tests against actual GCP project and real instances (`--type real`)
- **Cloud Functions**: All Cloud Function tests combined (`--type cloud-functions`)

## 📚 Documentation

- [Terraform Documentation](https://www.terraform.io/docs)
- [Google Cloud Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Firestore Documentation](https://cloud.google.com/firestore/docs)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Important Notes

- **Cost Management**: Monitor your GCP billing to avoid unexpected charges
- **Security**: Review IAM permissions and security rules before deployment
- **Backup**: Implement proper backup strategies for your data
- **Testing**: Always test in a development environment first
- **Variables**: Never commit sensitive information in configuration files

## 🆘 Troubleshooting

### Common Issues

1. **Authentication Errors**:
   ```bash
   gcloud auth application-default login
   ```

2. **Permission Errors**:
   - Ensure your account has necessary IAM roles
   - Check project billing status

3. **BigQuery Dataset Issues**:
   - Verify dataset location matches your configuration
   - Check external table source URIs

4. **Firestore Database Issues**:
   - Ensure Firestore API is enabled
   - Check security rules configuration
   - Verify authentication setup

5. **Cloud Function Deployment**:
   - Ensure Cloud Functions API is enabled
   - Check function source code for syntax errors

### Getting Help

- Check the [Terraform documentation](https://www.terraform.io/docs)
- Review [Google Cloud documentation](https://cloud.google.com/docs)
- Open an issue in this repository for specific problems
