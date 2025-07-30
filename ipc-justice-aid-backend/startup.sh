#!/bin/bash

# Azure App Service startup script for Django
echo "Starting Django application..."

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Run database migrations
echo "Running database migrations..."
python manage.py migrate --noinput

#!/bin/bash

echo "Starting IPC Justice Aid Backend..."

# Wait for database to be ready
echo "Waiting for database..."
while ! nc -z db 5432; do
  sleep 0.1
done
echo "Database is ready!"

# Run database migrations
echo "Running database migrations..."
python manage.py makemigrations
python manage.py migrate

# Create superuser if it doesn't exist
echo "Creating superuser if it doesn't exist..."
python manage.py shell << EOF
from django.contrib.auth import get_user_model
from django.db import IntegrityError

User = get_user_model()
try:
    if not User.objects.filter(email='admin@ipcjusticeaid.com').exists():
        User.objects.create_superuser(
            email='admin@ipcjusticeaid.com',
            password='admin123',
            first_name='Admin',
            last_name='User'
        )
        print("Superuser created: admin@ipcjusticeaid.com / admin123")
    else:
        print("Superuser already exists")
except Exception as e:
    print(f"Error creating superuser: {e}")
EOF

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Start the Django development server
echo "Starting Django server..."
python manage.py runserver 0.0.0.0:8000

# Start Gunicorn
echo "Starting Gunicorn..."
# First install gunicorn if not available
python -m pip install gunicorn
gunicorn --bind 0.0.0.0:8000 aarogyarekha_backend.wsgi:application
