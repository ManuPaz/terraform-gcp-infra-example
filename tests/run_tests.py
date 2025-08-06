#!/usr/bin/env python3
"""
Complete test runner for the infrastructure project.
"""
import subprocess
import sys
import argparse
import os


def run_command(command, description):
    """Run a command and handle errors."""
    print(f"\n{'='*60}")
    print(f"Running: {description}")
    print(f"Command: {' '.join(command)}")
    print(f"{'='*60}\n")
    
    try:
        result = subprocess.run(command, check=True, capture_output=False)
        print(f"\n✅ {description} completed successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n❌ {description} failed with exit code {e.returncode}")
        return False


def main():
    """Run all tests in the project."""
    parser = argparse.ArgumentParser(description="Complete test runner for the infrastructure project")
    parser.add_argument(
        "--type", 
        choices=["all", "mock", "real", "cloud-functions", "unit", "integration"],
        default="all",
        help="Type of tests to run"
    )
    parser.add_argument(
        "--coverage", 
        action="store_true",
        help="Generate coverage report"
    )
    parser.add_argument(
        "--verbose", 
        action="store_true",
        help="Verbose output"
    )
    parser.add_argument(
        "--parallel", 
        action="store_true",
        help="Run tests in parallel (if supported)"
    )
    
    args = parser.parse_args()
    
    # Base pytest command
    pytest_cmd = ["python", "-m", "pytest", "-s"]  # -s shows prints
    
    if args.verbose:
        pytest_cmd.append("-v")
    
    if args.coverage:
        pytest_cmd.extend(["--cov=../src", "--cov-report=html:../htmlcov", "--cov-report=term-missing"])
    
    if args.parallel:
        pytest_cmd.extend(["-n", "auto"])
    
    success = True
    
    # Run tests based on type
    if args.type == "all":
        print("🚀 Running ALL tests in the project...")
        
        # 1. Unit tests (mock tests)
        success &= run_command(
            pytest_cmd + ["test_cloud_functions.py::test_cloud_function"], 
            "Unit tests (mock)"
        )
        
        # 2. Integration tests (real infrastructure)
        success &= run_command(
            pytest_cmd + ["test_cloud_functions.py::test_cloud_function_real_integration"], 
            "Integration tests (real)"
        )
        
        
        
    elif args.type == "mock":
        success = run_command(
            pytest_cmd + ["test_cloud_functions.py::test_cloud_function"], 
            "Mock tests"
        )
        
    elif args.type == "real":
        success = run_command(
            pytest_cmd + ["test_cloud_functions.py::test_cloud_function_real_integration"], 
            "Real integration tests"
        )
        
    elif args.type == "cloud-functions":
        success = run_command(
            pytest_cmd + ["test_cloud_functions.py"], 
            "All Cloud Function tests"
        )
        
    elif args.type == "unit":
        success = run_command(
            pytest_cmd + [".", "-m", "unit"], 
            "Unit tests"
        )
        
    elif args.type == "integration":
        success = run_command(
            pytest_cmd + [".", "-m", "integration"], 
            "Integration tests"
        )
    
    # Final summary
    print(f"\n{'='*60}")
    if success:
        print("🎉 ALL TESTS PASSED! 🎉")
        print("Your infrastructure is working correctly.")
    else:
        print("💥 SOME TESTS FAILED! 💥")
        print("Please check the errors above and fix the issues.")
    print(f"{'='*60}")
    
    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main() 