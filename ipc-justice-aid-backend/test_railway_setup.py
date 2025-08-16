#!/usr/bin/env python
"""
Railway Deployment Test Script
Run this locally to verify your settings work before deploying
"""

import os
import sys
import django

def test_railway_setup():
    print("🧪 Testing Railway Setup Configuration...")
    
    # Test environment variables
    print("\n📋 Environment Variables Check:")
    required_vars = [
        'SECRET_KEY',
        'DATABASE_URL', 
        'GOOGLE_CLIENT_ID',
        'GOOGLE_CLIENT_SECRET',
        'HUGGINGFACE_API_TOKEN'
    ]
    
    for var in required_vars:
        value = os.getenv(var)
        if value:
            print(f"  ✅ {var}: {value[:20]}..." if len(value) > 20 else f"  ✅ {var}: {value}")
        else:
            print(f"  ❌ {var}: NOT SET")
    
    # Test Django settings
    print("\n🔧 Django Settings Test:")
    try:
        os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ipc_justice_aid_backend.railway_settings')
        django.setup()
        
        from django.conf import settings
        print(f"  ✅ Settings Module: {settings.SETTINGS_MODULE}")
        print(f"  ✅ Debug Mode: {settings.DEBUG}")
        print(f"  ✅ Allowed Hosts: {settings.ALLOWED_HOSTS}")
        print(f"  ✅ Database Engine: {settings.DATABASES['default']['ENGINE']}")
        
    except Exception as e:
        print(f"  ❌ Django Setup Error: {e}")
        return False
    
    # Test database connection
    print("\n💾 Database Connection Test:")
    try:
        from django.db import connection
        cursor = connection.cursor()
        cursor.execute("SELECT 1")
        print("  ✅ Database connection successful")
    except Exception as e:
        print(f"  ❌ Database connection failed: {e}")
        return False
    
    # Test migrations
    print("\n🔄 Migration Check:")
    try:
        from django.core.management import execute_from_command_line
        execute_from_command_line(['manage.py', 'migrate', '--check'])
        print("  ✅ All migrations applied")
    except Exception as e:
        print(f"  ⚠️ Migration issues: {e}")
    
    # Test imports
    print("\n📦 Import Test:")
    try:
        from ipc_analysis.views import health_check
        from authentication.models import User
        from ipc_analysis.services import AdaptiveAnalysisService
        print("  ✅ All critical imports successful")
    except Exception as e:
        print(f"  ❌ Import error: {e}")
        return False
    
    print("\n🎉 Railway setup test completed successfully!")
    print("\n📝 Next steps:")
    print("  1. Commit all changes to Git")
    print("  2. Push to your repository")
    print("  3. Deploy on Railway with the environment variables")
    print("  4. Check Railway logs for any issues")
    
    return True

if __name__ == "__main__":
    # Load environment variables from file if exists
    if os.path.exists('.env.railway'):
        print("📄 Loading .env.railway file...")
        with open('.env.railway', 'r') as f:
            for line in f:
                if '=' in line and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    os.environ[key] = value
    
    success = test_railway_setup()
    sys.exit(0 if success else 1)
