#!/bin/bash

# Railway startup script for Django
set -e

echo "🚀 Starting Railway deployment for Juris-Lead..."

# Set default port if not provided
export PORT=${PORT:-8000}

echo "📊 Environment Check:"
echo "  PORT: $PORT"
echo "  DEBUG: $DEBUG"
echo "  DATABASE_URL: ${DATABASE_URL:0:50}..."

# Function to wait for database
wait_for_db() {
    echo "⏳ Waiting for database connection..."
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if python -c "
import os
import sys
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ipc_justice_aid_backend.settings')
django.setup()
from django.db import connection
try:
    connection.ensure_connection()
    print('✅ Database connection successful')
    sys.exit(0)
except Exception as e:
    print(f'❌ Database connection failed: {e}')
    sys.exit(1)
"; then
            echo "✅ Database is ready!"
            return 0
        else
            echo "⏳ Database not ready yet (attempt $attempt/$max_attempts)..."
            sleep 5
            ((attempt++))
        fi
    done
    
    echo "❌ Database failed to become ready after $max_attempts attempts"
    return 1
}

# Wait for database
wait_for_db

# Run database migrations
echo "🔄 Running database migrations..."
python manage.py migrate --noinput
if [ $? -eq 0 ]; then
    echo "✅ Migrations completed successfully"
else
    echo "❌ Migration failed"
    exit 1
fi

# Collect static files
echo "📁 Collecting static files..."
python manage.py collectstatic --noinput
if [ $? -eq 0 ]; then
    echo "✅ Static files collected successfully"
else
    echo "⚠️ Static files collection failed, but continuing..."
fi

# Check if we can import Django successfully
echo "🔍 Testing Django import..."
python -c "
import django
from django.conf import settings
print(f'✅ Django {django.get_version()} imported successfully')
print(f'✅ Settings module: {settings.SETTINGS_MODULE}')
"

# Create cache table if using database cache
echo "📦 Creating cache table (if needed)..."
python manage.py createcachetable || echo "⚠️ Cache table creation skipped"

echo "🎯 Starting Gunicorn server..."
echo "  Binding to: 0.0.0.0:$PORT"
echo "  Workers: 2"
echo "  Timeout: 120s"

# Start Gunicorn with optimized settings for Railway
exec gunicorn ipc_justice_aid_backend.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 2 \
    --worker-class sync \
    --timeout 120 \
    --keep-alive 5 \
    --max-requests 1000 \
    --max-requests-jitter 100 \
    --preload \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    --capture-output
