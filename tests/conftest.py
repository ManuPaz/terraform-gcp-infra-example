"""
Basic pytest configuration for infrastructure tests.
"""
import os
import sys

# Add the src directory to the path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src')) 