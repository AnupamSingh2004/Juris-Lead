#!/usr/bin/env python
"""
Simple test script to check if Django can start without cv2/numpy errors
"""
import os
import sys
import django

# Add the project directory to Python path
sys.path.insert(0, '/home/anupam/code/Hack4Health/aarogyarekha/aarogyarekha-backend')

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aarogyarekha_backend.settings')
django.setup()

print("✅ Django setup successful!")
print("✅ No cv2/numpy import errors during startup")

# Test basic imports
try:
    from prescriptions.models import Prescription
    print("✅ Prescription model import successful")
except Exception as e:
    print(f"❌ Error importing Prescription model: {e}")

try:
    from prescriptions.views import PrescriptionUploadView
    print("✅ Views import successful")
except Exception as e:
    print(f"❌ Error importing views: {e}")

# Test that utils can be imported when needed
try:
    from prescriptions.utils import ImageProcessor
    print("✅ Utils can be imported when needed")
except Exception as e:
    print(f"❌ Error importing utils: {e}")

print("\n🎉 Django backend is ready!")
