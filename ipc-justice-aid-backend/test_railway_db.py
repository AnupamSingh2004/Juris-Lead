#!/usr/bin/env python3
"""
Test Railway Database Connection
This script tests the Railway PostgreSQL connection directly
"""

import os
import sys
import psycopg2
from urllib.parse import urlparse

def test_railway_database():
    """Test connection to Railway PostgreSQL database"""
    
    # Your Railway database URL
    database_url = "postgresql://postgres:eczgodRmYkhhwbBhdwlNSnroAxBtXKoA@yamanote.proxy.rlwy.net:22722/railway"
    
    print("🔍 Testing Railway Database Connection")
    print(f"Database URL: {database_url[:50]}...")
    
    try:
        # Parse the database URL
        parsed = urlparse(database_url)
        print(f"Host: {parsed.hostname}")
        print(f"Port: {parsed.port}")
        print(f"Database: {parsed.path[1:]}")  # Remove leading slash
        print(f"Username: {parsed.username}")
        
        # Test connection
        print("\n🔌 Attempting connection...")
        conn = psycopg2.connect(database_url)
        
        # Test query
        print("✅ Connection successful! Testing query...")
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()
        print(f"PostgreSQL Version: {version[0]}")
        
        # Test basic operations
        cursor.execute("SELECT 1 as test;")
        result = cursor.fetchone()
        print(f"Test query result: {result[0]}")
        
        cursor.close()
        conn.close()
        
        print("✅ Database connection test PASSED!")
        return True
        
    except Exception as e:
        print(f"❌ Database connection test FAILED!")
        print(f"Error: {str(e)}")
        print(f"Error type: {type(e).__name__}")
        return False

def test_django_with_railway_db():
    """Test Django with Railway database"""
    
    print("\n🐍 Testing Django with Railway Database")
    
    # Set environment variables
    os.environ['DATABASE_URL'] = "postgresql://postgres:eczgodRmYkhhwbBhdwlNSnroAxBtXKoA@yamanote.proxy.rlwy.net:22722/railway"
    os.environ['SECRET_KEY'] = 'test-secret-key-for-testing'
    os.environ['DEBUG'] = 'True'
    os.environ['ALLOWED_HOSTS'] = 'localhost,127.0.0.1'
    
    try:
        # Test Django setup
        import django
        from django.conf import settings
        
        # Configure Django
        if not settings.configured:
            settings.configure(
                DEBUG=True,
                SECRET_KEY='test-secret-key',
                DATABASES={
                    'default': {
                        'ENGINE': 'django.db.backends.postgresql',
                        'NAME': 'railway',
                        'USER': 'postgres',
                        'PASSWORD': 'eczgodRmYkhhwbBhdwlNSnroAxBtXKoA',
                        'HOST': 'yamanote.proxy.rlwy.net',
                        'PORT': '22722',
                        'OPTIONS': {
                            'connect_timeout': 60,
                        },
                    }
                },
                INSTALLED_APPS=[
                    'django.contrib.contenttypes',
                    'django.contrib.auth',
                ]
            )
        
        django.setup()
        
        # Test database connection
        from django.db import connection
        cursor = connection.cursor()
        cursor.execute("SELECT 1")
        result = cursor.fetchone()
        
        print(f"✅ Django database test PASSED! Result: {result[0]}")
        return True
        
    except Exception as e:
        print(f"❌ Django database test FAILED!")
        print(f"Error: {str(e)}")
        import traceback
        print(traceback.format_exc())
        return False

if __name__ == "__main__":
    print("🚀 Railway Database Connection Tests")
    print("=" * 50)
    
    # Test 1: Direct PostgreSQL connection
    db_test = test_railway_database()
    
    # Test 2: Django with Railway database
    django_test = test_django_with_railway_db()
    
    print("\n" + "=" * 50)
    print("📊 Test Results:")
    print(f"Direct PostgreSQL: {'✅ PASS' if db_test else '❌ FAIL'}")
    print(f"Django Integration: {'✅ PASS' if django_test else '❌ FAIL'}")
    
    if db_test and django_test:
        print("🎉 All tests PASSED! Railway database is working.")
    else:
        print("🚨 Some tests FAILED! Check the errors above.")
