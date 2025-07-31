#!/bin/bash

# Juris-Lead Platform Startup Script
echo "🏛️ Starting IPC Justice Aid - Juris-Lead Platform..."

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
python manage.py shell -c "
import django
django.setup()
from django.db import connection
import time
import sys

for i in range(30):
    try:
        connection.ensure_connection()
        print('Database is ready!')
        break
    except:
        print(f'Database not ready, waiting... ({i+1}/30)')
        time.sleep(2)
else:
    print('Database connection failed!')
    sys.exit(1)
"

# Run migrations
echo "🔄 Running database migrations..."
python manage.py makemigrations
python manage.py migrate

# Create leads migrations specifically
echo "🔄 Creating leads app migrations..."
python manage.py makemigrations leads
python manage.py migrate leads

# Load IPC sections data if available
echo "📚 Loading IPC sections data..."
python manage.py shell -c "
from ipc_analysis.models import IPCSection
import json

# Sample IPC sections data
ipc_data = [
    {'section_number': '302', 'title': 'Punishment for murder', 'description': 'Whoever commits murder shall be punished with death, or imprisonment for life, and shall also be liable to fine.'},
    {'section_number': '304', 'title': 'Punishment for culpable homicide not amounting to murder', 'description': 'Whoever commits culpable homicide not amounting to murder shall be punished with imprisonment for life, or imprisonment of either description for a term which may extend to ten years, and shall also be liable to fine.'},
    {'section_number': '304B', 'title': 'Dowry death', 'description': 'Where the death of a woman is caused by any burns or bodily injury or occurs otherwise than under normal circumstances within seven years of her marriage and it is shown that soon before her death she was subjected to cruelty or harassment by her husband or any relative of her husband for, or in connection with, any demand for dowry, such death shall be called dowry death, and such husband or relative shall be deemed to have caused her death.'},
    {'section_number': '307', 'title': 'Attempt to murder', 'description': 'Whoever does any act with such intention or knowledge, and under such circumstances that, if he by that act caused death, he would be guilty of murder, shall be punished with imprisonment of either description for a term which may extend to ten years, and shall also be liable to fine.'},
    {'section_number': '323', 'title': 'Punishment for voluntarily causing hurt', 'description': 'Whoever, except in the case provided for by section 334, voluntarily causes hurt, shall be punished with imprisonment of either description for a term which may extend to one year, or with fine which may extend to one thousand rupees, or with both.'},
    {'section_number': '376', 'title': 'Punishment for rape', 'description': 'Whoever commits rape shall be punished with rigorous imprisonment of either description for a term which shall not be less than ten years, but which may extend to imprisonment for life, and shall also be liable to fine.'},
    {'section_number': '420', 'title': 'Cheating and dishonestly inducing delivery of property', 'description': 'Whoever cheats and thereby dishonestly induces the person deceived to deliver any property to any person, or to make, alter or destroy the whole or any part of a valuable security, or anything which is signed or sealed, and which is capable of being converted into a valuable security, shall be punished with imprisonment of either description for a term which may extend to seven years, and shall also be liable to fine.'},
    {'section_number': '498A', 'title': 'Husband or relative of husband of a woman subjecting her to cruelty', 'description': 'Whoever, being the husband or the relative of the husband of a woman, subjects such woman to cruelty shall be punished with imprisonment for a term which may extend to three years and shall also be liable to fine.'},
]

for section_data in ipc_data:
    section, created = IPCSection.objects.get_or_create(
        section_number=section_data['section_number'],
        defaults={
            'title': section_data['title'],
            'description': section_data['description']
        }
    )
    if created:
        print(f'Created IPC Section {section.section_number}')
    else:
        print(f'IPC Section {section.section_number} already exists')
"

# Create superuser if it doesn't exist
echo "👤 Creating admin user..."
python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@ipc-justice-aid.com', 'admin123')
    print('Admin user created: admin/admin123')
else:
    print('Admin user already exists')
"

# Collect static files
echo "📁 Collecting static files..."
python manage.py collectstatic --noinput

# Check Ollama connection
echo "🤖 Testing Ollama connection..."
python manage.py shell -c "
from leads.services import OllamaIPCService
import sys

try:
    service = OllamaIPCService()
    is_connected, message = service.test_connection()
    if is_connected:
        print('✅ Ollama service is connected and ready')
        print(f'   {message}')
    else:
        print('❌ Ollama service connection failed')
        print(f'   {message}')
        print('   Make sure Ollama is running and the model is available')
except Exception as e:
    print(f'❌ Ollama test failed: {str(e)}')
    print('   The platform will work but AI analysis will be limited')
"

# Start the development server
echo "🚀 Starting Django development server..."
echo "📊 Dashboard will be available at: http://localhost:8000/admin/"
echo "🔍 API documentation: http://localhost:8000/api/docs/"
echo "⚖️ Citizen platform: http://localhost:8000/api/v1/leads/analyze-case/"
echo "👩‍💼 Lawyer dashboard: http://localhost:8000/api/v1/leads/dashboard/"

# Run the server
python manage.py runserver 0.0.0.0:8000
