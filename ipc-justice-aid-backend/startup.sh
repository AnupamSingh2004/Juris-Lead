#!/bin/bash

echo "Starting IPC Justice Aid Backend..."

# Function to wait for database connection
wait_for_db() {
    echo "Waiting for database connection..."
    
    # Check if running in Azure or Docker
    if [ "$AZURE_APP_SERVICE" = "True" ]; then
        # Azure - database should be ready, but add a small delay
        sleep 5
        echo "Azure database should be ready"
    else
        # Docker/Local - wait for database container
        while ! nc -z "${DATABASE_HOST:-db}" "${DATABASE_PORT:-5432}"; do
            echo "Waiting for database at ${DATABASE_HOST:-db}:${DATABASE_PORT:-5432}..."
            sleep 1
        done
        echo "Database is ready!"
    fi
}

# Wait for database
wait_for_db

# Run database migrations
echo "Running database migrations..."
python manage.py makemigrations --noinput
python manage.py migrate --noinput

# Create superuser if it doesn't exist (only in development)
if [ "$DEBUG" = "True" ]; then
    echo "Creating development superuser if it doesn't exist..."
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
        print("Development superuser created: admin@ipcjusticeaid.com / admin123")
    else:
        print("Superuser already exists")
except Exception as e:
    print(f"Error creating superuser: {e}")
EOF
fi

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Start the application
if [ "$DEBUG" = "True" ]; then
    echo "Starting Django development server..."
    python manage.py runserver 0.0.0.0:8000 --noreload
else
    echo "Starting Gunicorn production server..."
    exec gunicorn --bind 0.0.0.0:8000 \
                  --workers 3 \
                  --timeout 300 \
                  --keep-alive 2 \
                  --max-requests 1000 \
                  --max-requests-jitter 100 \
                  --access-logfile - \
                  --error-logfile - \
                  --log-level info \
                  ipc_justice_aid_backend.wsgi:application
fi
