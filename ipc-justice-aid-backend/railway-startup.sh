#!/bin/bash

# Railway startup script for Django
set -e

echo "Starting Railway deployment..."

# Check if we're in Railway environment
if [ "$RAILWAY_ENVIRONMENT" ]; then
    echo "Railway environment detected: $RAILWAY_ENVIRONMENT"
fi

# Wait for database to be ready (Railway handles this automatically, but good to have)
echo "Checking database connection..."
python -c "
import os
import django
from django.conf import settings
from django.core.management import execute_from_command_line

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ipc_justice_aid_backend.settings')
django.setup()

from django.db import connection
try:
    cursor = connection.cursor()
    print('Database connection successful')
except Exception as e:
    print(f'Database connection failed: {e}')
    exit(1)
"

# Run database migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create superuser if it doesn't exist (optional)
echo "Checking for superuser..."
python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(is_superuser=True).exists():
    print('No superuser found. You can create one later.')
else:
    print('Superuser already exists.')
" || echo "Superuser check completed"

echo "Starting Django application..."
exec gunicorn ipc_justice_aid_backend.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 2 \
    --timeout 120 \
    --keep-alive 5 \
    --max-requests 1000 \
    --max-requests-jitter 100 \
    --access-logfile - \
    --error-logfile -
