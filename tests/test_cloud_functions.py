"""
Basic test for Cloud Functions.
"""
import os
import sys
import pytest
import re
from unittest.mock import Mock, patch

# Add the src directory to the path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

# Import the Cloud Function
from cloud_functions.alerts.compute_engine_on.main import check_instances_and_notify


def read_terraform_vars():
    """Read variables from terraform.tfvars file."""
    tfvars_path = os.path.join(os.path.dirname(__file__), '..', 'terraform', 'terraform.tfvars')
    
    if not os.path.exists(tfvars_path):
        print(f"⚠️  No terraform.tfvars found at {tfvars_path}")
        print("   Using default values for testing")
        return {
            'alert_email': 'test@example.com',
            'smtp_password': 'test-password',
            'alert_threshold_minutes': '0',
            'compute_zones': ['europe-west1-b', 'europe-west1-c']
        }
    
    variables = {}
    
    try:
        with open(tfvars_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Extract variables using regex
        # alert_email = "tu-email@gmail.com"
        email_match = re.search(r'alert_email\s*=\s*"([^"]+)"', content)
        if email_match:
            variables['alert_email'] = email_match.group(1)
        
        # smtp_password = "tu-app-password-de-gmail"
        password_match = re.search(r'smtp_password\s*=\s*"([^"]+)"', content)
        if password_match:
            variables['smtp_password'] = password_match.group(1)
        
        # alert_threshold_minutes = 30
        threshold_match = re.search(r'alert_threshold_minutes\s*=\s*(\d+)', content)
        if threshold_match:
            variables['alert_threshold_minutes'] = threshold_match.group(1)
        
        # compute_zones = ["europe-west1-b", "europe-west1-c"]
        zones_match = re.search(r'compute_zones\s*=\s*\[(.*?)\]', content, re.DOTALL)
        if zones_match:
            zones_str = zones_match.group(1)
            zones = re.findall(r'"([^"]+)"', zones_str)
            variables['compute_zones'] = zones
        
        print(f"✅ Read Terraform variables: {list(variables.keys())}")
        return variables
        
    except Exception as e:
        print(f"❌ Error reading terraform.tfvars: {e}")
        return {
            'alert_email': 'test@example.com',
            'smtp_password': 'test-password',
            'alert_threshold_minutes': '30',
            'compute_zones': ['europe-west1-b', 'europe-west1-c']
        }


@pytest.mark.unit
def test_cloud_function():
    """Basic test for the Cloud Function."""
    print("\n🧪 Starting UNIT test (with mocks)...")
    
    # Read real credentials from Terraform
    tf_vars = read_terraform_vars()
    print(f"📋 Terraform variables loaded: {list(tf_vars.keys())}")
    
    # Set environment variables for testing
    os.environ['ALERT_THRESHOLD_MINUTES'] = tf_vars.get('alert_threshold_minutes', '30')
    os.environ['COMPUTE_ZONES'] = ','.join(tf_vars.get('compute_zones', ['europe-west1-b', 'europe-west1-c']))
    os.environ['EMAIL'] = tf_vars.get('alert_email', 'test@example.com')
    os.environ['SMTP_PASSWORD'] = tf_vars.get('smtp_password', 'test-password')
    
    print(f"⚙️  Environment variables set:")
    print(f"   - ALERT_THRESHOLD_MINUTES: {os.environ['ALERT_THRESHOLD_MINUTES']}")
    print(f"   - COMPUTE_ZONES: {os.environ['COMPUTE_ZONES']}")
    print(f"   - EMAIL: {os.environ['EMAIL']}")
    print(f"   - SMTP_PASSWORD: {'*' * len(os.environ['SMTP_PASSWORD']) if os.environ['SMTP_PASSWORD'] else 'NOT SET'}")

    # Mock request object
    mock_request = Mock()
    mock_request.method = 'POST'
    mock_request.headers = {}
    mock_request.data = b'{"test": "data"}'

    # Mock Google Cloud services
    with patch('cloud_functions.alerts.compute_engine_on.main.google.auth.default') as mock_auth, \
         patch('cloud_functions.alerts.compute_engine_on.main.build') as mock_build, \
         patch('cloud_functions.alerts.compute_engine_on.main.send_email') as mock_send_email:
        
        # Setup mocks
        mock_credentials = Mock()
        mock_project = 'test-project'
        mock_auth.return_value = (mock_credentials, mock_project)
        
        mock_compute = Mock()
        mock_build.return_value = mock_compute
        
        # Mock empty instances list (no instances to test)
        mock_compute.instances.return_value.list.return_value.execute.return_value = {}
        
        # Call the function
        print("🚀 Calling Cloud Function...")
        result = check_instances_and_notify(mock_request)
        
        # Verify the result
        assert result == "Done"
        print("✅ Cloud Function test passed!")
        print("🎉 UNIT test completed successfully!")


@pytest.mark.integration
def test_cloud_function_real_integration():
    """Integration test using real Google Cloud infrastructure - NO MOCKS."""
    print("\n🔍 Starting REAL integration test with Google Cloud...")
    
    # Read real credentials from Terraform
    tf_vars = read_terraform_vars()
    print(f"📋 Terraform variables loaded: {list(tf_vars.keys())}")
    
    # Check if we have real credentials
    credentials_path = os.path.join(os.path.dirname(__file__), '..', 'credentials', 'gcp', 'finance-pro.json')
    if not os.path.exists(credentials_path):
        print("❌ No credentials found at credentials/gcp/finance-pro.json")
        print("   Skipping real integration test")
        raise
    
    # Set real environment variables from Terraform
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path
    os.environ['ALERT_THRESHOLD_MINUTES'] = tf_vars.get('alert_threshold_minutes', '30')
    os.environ['COMPUTE_ZONES'] = ','.join(tf_vars.get('compute_zones', ['europe-west1-b', 'europe-west1-c']))
    os.environ['EMAIL'] = tf_vars.get('alert_email')
    os.environ['SMTP_PASSWORD'] = tf_vars.get('smtp_password', '')
    
    print(f"📧 Using email: {tf_vars.get('alert_email')}")
    print(f"⏰ Threshold: {tf_vars.get('alert_threshold_minutes', '30')} minutes")
    print(f"🌍 Zones: {tf_vars.get('compute_zones', ['europe-west1-b', 'europe-west1-c'])}")
    print(f"🔑 SMTP Password: {'*' * len(tf_vars.get('smtp_password', '')) if tf_vars.get('smtp_password') else 'NOT SET'}")
    
    # Create real request object
    mock_request = Mock()
    mock_request.method = 'POST'
    mock_request.headers = {}
    mock_request.data = b'{"test": "real_integration"}'
    
    try:
        print("📡 Connecting to real Google Cloud...")
        print("🚀 Calling Cloud Function with REAL infrastructure...")
        
        # Call the function with REAL infrastructure
        result = check_instances_and_notify(mock_request)
        
        # Verify the result
        assert result == "Done"
        print("✅ Real integration test passed!")
        print("   Function successfully connected to Google Cloud")
        print("   Checked real Compute Engine instances")
        print("🎉 INTEGRATION test completed successfully!")
        
    except Exception as e:
        error_msg = str(e)
        print(f"❌ Real integration test failed: {error_msg}")
        raise
        
        if "403" in error_msg and "compute.instances.list" in error_msg:
            print("\n🔧 PERMISSION ERROR DETECTED!")
            print("   The service account doesn't have permission to list Compute Engine instances.")
            print("\n   Solutions:")
            print("   1. Use user credentials instead:")
            print("      gcloud auth application-default login")
            print("\n   2. Or give permissions to service account:")
            print("      gcloud projects add-iam-policy-binding PROJECT-ID \\")
            print("          --member=\"serviceAccount:YOUR-SA@PROJECT-ID.iam.gserviceaccount.com\" \\")
            print("          --role=\"roles/compute.viewer\"")
            print("\n   3. Or run the mock test instead:")
            print("      python run_tests.py --type mock")
            
            # Don't fail the test, just skip it
            pytest.skip("Permission error - service account needs compute.viewer role")
        else:
            print("   This might be due to:")
            print("   - Invalid credentials")
            print("   - No access to Compute Engine")
            print("   - Network connectivity issues")
            raise


if __name__ == "__main__":
    test_cloud_function()
    test_cloud_function_real_integration() 