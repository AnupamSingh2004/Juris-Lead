#!/bin/bash
# Build script for Render

set -o errexit  # Exit on error

echo "🚀 Starting Render deployment build..."

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install --upgrade pip

# Use optimized requirements for Render if available, otherwise use default
if [ -f "requirements.render.txt" ]; then
    echo "Using optimized requirements for Render..."
    pip install -r requirements.render.txt
else
    echo "Using default requirements..."
    pip install -r requirements.txt
fi

# Set environment for production
export DEBUG=False
export ANALYSIS_ENVIRONMENT=gemini

# Collect static files for Django
echo "📁 Collecting static files..."
python manage.py collectstatic --noinput

# Run database migrations
echo "🗄️ Running database migrations..."
python manage.py migrate

# Create superuser if specified (optional)
if [ "$DJANGO_SUPERUSER_EMAIL" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ]; then
    echo "👤 Creating superuser..."
    python manage.py shell -c "
import os
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='$DJANGO_SUPERUSER_EMAIL').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')
    print('Superuser created successfully')
else:
    print('Superuser already exists')
"
fi

echo "✅ Build completed successfully!"
