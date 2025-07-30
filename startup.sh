#!/bin/bash

# AarogyaRekha Django App Startup Script for Azure App Service
# This script runs when the Azure container starts

# Don't exit on error initially - we want to see what fails
set +e

echo "🚀 Starting AarogyaRekha Django Application..."
echo "📍 Current working directory: $(pwd)"
echo "📁 Contents of /home/site/wwwroot:"
ls -la /home/site/wwwroot/

# Change to the backend directory
echo "📂 Changing to backend directory..."
cd /home/site/wwwroot/aarogyarekha-backend

if [ $? -ne 0 ]; then
    echo "❌ Failed to change to backend directory"
    echo "📁 Current directory contents:"
    ls -la /home/site/wwwroot/
    exit 1
fi

echo "📁 Backend directory contents:"
ls -la

# Check if requirements.txt exists
if [ ! -f "requirements.txt" ]; then
    echo "❌ requirements.txt not found in $(pwd)"
    exit 1
fi

# Install any missing requirements
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Check if manage.py exists
if [ ! -f "manage.py" ]; then
    echo "❌ manage.py not found in $(pwd)"
    exit 1
fi

# Set environment variables for Django if not set
export DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE:-aarogyarekha_backend.settings}

# Create logs directory if it doesn't exist
mkdir -p logs

echo "🔧 Environment check..."
echo "SECRET_KEY set: ${SECRET_KEY:+YES}"
echo "DEBUG: ${DEBUG:-Not set}"
echo "DATABASE_HOST: ${DATABASE_HOST:-Not set}"

# Try to collect static files (don't fail if this doesn't work)
echo "📁 Collecting static files..."
python manage.py collectstatic --noinput --clear || echo "⚠️ Static file collection failed, continuing..."

# Run database migrations (don't fail if this doesn't work initially)
echo "🗄️ Running database migrations..."
python manage.py migrate --noinput || echo "⚠️ Database migration failed, continuing..."

# Create superuser if credentials are provided
if [ "$DJANGO_SUPERUSER_EMAIL" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ]; then
    echo "👤 Creating Django superuser..."
    python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='$DJANGO_SUPERUSER_EMAIL').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')
    print('Superuser created successfully')
else:
    print('Superuser already exists')
" || echo "⚠️ Superuser creation failed, continuing..."
fi

# Check if gunicorn is available
echo "🔍 Checking for gunicorn..."
which gunicorn || pip install gunicorn

# Start the Django application using Gunicorn
echo "🌐 Starting Django with Gunicorn..."
echo "🔧 Gunicorn command: gunicorn --bind=0.0.0.0:8000 --workers=3 --timeout=600 --access-logfile='-' --error-logfile='-' aarogyarekha_backend.wsgi:application"

# Enable error exit for the final command
set -e
exec gunicorn --bind=0.0.0.0:8000 --workers=3 --timeout=600 --access-logfile='-' --error-logfile='-' aarogyarekha_backend.wsgi:application
