#!/bin/bash

# Ultra-detailed Railway startup script for debugging
set -e  # Exit on any error

echo "🚀 === RAILWAY DEPLOYMENT DEBUG STARTUP ==="
echo "📅 Timestamp: $(date)"
echo "🖥️  Platform: $(uname -a)"
echo "🐍 Python version: $(python --version)"
echo "📦 Pip version: $(pip --version)"

# Environment check
echo ""
echo "🔍 === ENVIRONMENT VARIABLES CHECK ==="
echo "PORT: ${PORT:-NOT_SET}"
echo "DEBUG: ${DEBUG:-NOT_SET}"
echo "SECRET_KEY: ${SECRET_KEY:0:20}... (length: ${#SECRET_KEY})"
echo "DATABASE_URL: ${DATABASE_URL:0:50}..."
echo "DJANGO_SETTINGS_MODULE: ${DJANGO_SETTINGS_MODULE:-NOT_SET}"
echo "ALLOWED_HOSTS: ${ALLOWED_HOSTS:-NOT_SET}"
echo "HUGGINGFACE_API_TOKEN: ${HUGGINGFACE_API_TOKEN:0:10}..."

# Directory check
echo ""
echo "📁 === DIRECTORY AND FILES CHECK ==="
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la
echo ""
echo "Python path:"
echo $PYTHONPATH
echo ""
echo "Checking for manage.py:"
if [ -f "manage.py" ]; then
    echo "✅ manage.py found"
else
    echo "❌ manage.py not found!"
    exit 1
fi

# Django check
echo ""
echo "🔧 === DJANGO SETUP TEST ==="
echo "Testing Django import..."
python -c "
import django
print(f'✅ Django version: {django.get_version()}')
"

echo "Testing settings import..."
python -c "
import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${DJANGO_SETTINGS_MODULE:-ipc_justice_aid_backend.settings}')
import django
django.setup()
from django.conf import settings
print(f'✅ Settings loaded: {settings.SETTINGS_MODULE}')
print(f'✅ Debug mode: {settings.DEBUG}')
print(f'✅ Secret key length: {len(settings.SECRET_KEY)}')
print(f'✅ Allowed hosts: {settings.ALLOWED_HOSTS}')
"

# Database connection test
echo ""
echo "💾 === DATABASE CONNECTION TEST ==="
echo "Testing database connection..."
python -c "
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${DJANGO_SETTINGS_MODULE:-ipc_justice_aid_backend.settings}')
django.setup()

try:
    from django.db import connection
    cursor = connection.cursor()
    cursor.execute('SELECT 1')
    result = cursor.fetchone()
    print(f'✅ Database connection successful! Result: {result}')
    
    # Get database info
    db_settings = connection.settings_dict
    print(f'✅ Database engine: {db_settings.get(\"ENGINE\", \"unknown\")}')
    print(f'✅ Database name: {db_settings.get(\"NAME\", \"unknown\")}')
    print(f'✅ Database host: {db_settings.get(\"HOST\", \"unknown\")}')
    
except Exception as e:
    print(f'❌ Database connection failed: {e}')
    import traceback
    traceback.print_exc()
    exit(1)
"

# Critical imports test
echo ""
echo "📦 === CRITICAL IMPORTS TEST ==="
python -c "
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${DJANGO_SETTINGS_MODULE:-ipc_justice_aid_backend.settings}')
django.setup()

imports = [
    'rest_framework',
    'authentication',
    'authentication.models',
    'ipc_analysis',
    'ipc_analysis.views',
    'leads',
]

for module in imports:
    try:
        __import__(module)
        print(f'✅ Import successful: {module}')
    except Exception as e:
        print(f'❌ Import failed: {module} - {e}')
"

# Run migrations
echo ""
echo "🔄 === DATABASE MIGRATIONS ==="
echo "Running migrations..."
python manage.py migrate --noinput --verbosity=2
if [ $? -eq 0 ]; then
    echo "✅ Migrations completed successfully"
else
    echo "❌ Migrations failed!"
    exit 1
fi

# Collect static files
echo ""
echo "📁 === STATIC FILES COLLECTION ==="
echo "Collecting static files..."
python manage.py collectstatic --noinput --verbosity=2
if [ $? -eq 0 ]; then
    echo "✅ Static files collected successfully"
else
    echo "⚠️ Static files collection failed, but continuing..."
fi

# Test URL patterns
echo ""
echo "🌐 === URL PATTERNS TEST ==="
python -c "
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${DJANGO_SETTINGS_MODULE:-ipc_justice_aid_backend.settings}')
django.setup()

try:
    from django.urls import get_resolver
    resolver = get_resolver()
    print('✅ URL patterns loaded successfully')
    
    # Test specific endpoints
    from django.test import Client
    client = Client()
    
    # Test debug endpoint
    response = client.get('/api/v1/debug/')
    print(f'✅ Debug endpoint status: {response.status_code}')
    
except Exception as e:
    print(f'❌ URL patterns test failed: {e}')
    import traceback
    traceback.print_exc()
"

# Final startup
echo ""
echo "🎯 === STARTING GUNICORN SERVER ==="
echo "Server configuration:"
echo "  Bind: 0.0.0.0:${PORT:-8000}"
echo "  Workers: 1 (debug mode)"
echo "  Timeout: 120s"
echo "  Log level: debug"

exec gunicorn ipc_justice_aid_backend.wsgi:application \
    --bind 0.0.0.0:${PORT:-8000} \
    --workers 1 \
    --worker-class sync \
    --timeout 120 \
    --keep-alive 5 \
    --max-requests 100 \
    --preload \
    --access-logfile - \
    --error-logfile - \
    --log-level debug \
    --capture-output
