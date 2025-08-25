#!/usr/bin/env python
"""
Health check script for IPC Justice Aid Backend on Render
Run this script to verify that all services are working correctly
"""

import os
import sys
import django
import requests
import json
from urllib.parse import urljoin

# Add the project directory to Python path
project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(project_dir)

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ipc_justice_aid_backend.settings')
django.setup()

from django.conf import settings
from django.db import connection
from django.core.cache import cache
from ipc_analysis.adaptive_service import adaptive_analysis_service


def check_database():
    """Check database connectivity"""
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        return True, "Database connection successful"
    except Exception as e:
        return False, f"Database connection failed: {str(e)}"


def check_redis():
    """Check Redis connectivity"""
    try:
        cache.set('health_check', 'ok', 10)
        result = cache.get('health_check')
        if result == 'ok':
            return True, "Redis connection successful"
        else:
            return False, "Redis connection failed: value mismatch"
    except Exception as e:
        return False, f"Redis connection failed: {str(e)}"


def check_analysis_service():
    """Check AI analysis service"""
    try:
        health = adaptive_analysis_service.health_check()
        if health.get('status') == 'healthy':
            return True, f"Analysis service ({health.get('service', 'unknown')}) is healthy"
        else:
            return False, f"Analysis service unhealthy: {health.get('error', 'unknown error')}"
    except Exception as e:
        return False, f"Analysis service check failed: {str(e)}"


def check_huggingface_api():
    """Check Hugging Face API connectivity"""
    try:
        from ipc_analysis.huggingface_service import HuggingFaceService
        
        service = HuggingFaceService()
        if not service.api_token:
            return False, "Hugging Face API token not configured"
        
        health = service.health_check()
        if health.get('status') == 'healthy':
            return True, f"Hugging Face API ({service.model_id}) is accessible"
        else:
            return False, f"Hugging Face API error: {health.get('error', 'unknown error')}"
    except Exception as e:
        return False, f"Hugging Face API check failed: {str(e)}"


def test_analysis_endpoint(base_url=None):
    """Test the analysis endpoint"""
    if not base_url:
        base_url = "http://localhost:8000"
    
    try:
        url = urljoin(base_url, "/leads/analyze-case/")
        payload = {
            "case_description": "A person threatened someone with a knife in a public place",
            "incident_date": "2024-01-15",
            "incident_location": "Mumbai, Maharashtra"
        }
        
        response = requests.post(
            url,
            json=payload,
            headers={'Content-Type': 'application/json'},
            timeout=60
        )
        
        if response.status_code == 200:
            data = response.json()
            if 'status' in data and data['status'] == 'success':
                return True, "Analysis endpoint working correctly"
            else:
                return False, f"Analysis endpoint returned unexpected format: {data}"
        else:
            return False, f"Analysis endpoint returned status {response.status_code}: {response.text}"
    
    except requests.exceptions.Timeout:
        return False, "Analysis endpoint timed out (>60s)"
    except Exception as e:
        return False, f"Analysis endpoint test failed: {str(e)}"


def main():
    """Run all health checks"""
    print("🏥 IPC Justice Aid Backend Health Check")
    print("=" * 50)
    
    checks = [
        ("Database", check_database),
        ("Redis Cache", check_redis),
        ("Analysis Service", check_analysis_service),
        ("Hugging Face API", check_huggingface_api),
    ]
    
    all_passed = True
    
    for check_name, check_func in checks:
        try:
            success, message = check_func()
            status = "✅ PASS" if success else "❌ FAIL"
            print(f"{status} {check_name}: {message}")
            
            if not success:
                all_passed = False
                
        except Exception as e:
            print(f"❌ FAIL {check_name}: Unexpected error - {str(e)}")
            all_passed = False
    
    print("\n" + "=" * 50)
    
    # Test analysis endpoint if specified
    if len(sys.argv) > 1:
        base_url = sys.argv[1]
        print(f"🧪 Testing analysis endpoint at {base_url}")
        success, message = test_analysis_endpoint(base_url)
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} Analysis Endpoint: {message}")
        
        if not success:
            all_passed = False
    
    # Summary
    if all_passed:
        print("\n🎉 All health checks passed! System is ready.")
        return 0
    else:
        print("\n⚠️  Some health checks failed. Please review the errors above.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
