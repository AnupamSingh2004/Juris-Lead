# Railway Production Settings
# This file contains settings optimized for Railway deployment

import os
import dj_database_url
from .settings import *

# Railway environment detection
RAILWAY_ENVIRONMENT = os.getenv('RAILWAY_ENVIRONMENT')
RAILWAY_PUBLIC_DOMAIN = os.getenv('RAILWAY_PUBLIC_DOMAIN')

print(f"🚀 Railway Settings Loaded")
print(f"   Environment: {RAILWAY_ENVIRONMENT}")
print(f"   Domain: {RAILWAY_PUBLIC_DOMAIN}")

# Security Settings for Production
DEBUG = False
SECRET_KEY = os.getenv('SECRET_KEY', 'django-insecure-railway-change-this')

# Allowed Hosts - Railway automatically provides RAILWAY_PUBLIC_DOMAIN
ALLOWED_HOSTS = []
if RAILWAY_PUBLIC_DOMAIN:
    ALLOWED_HOSTS.append(RAILWAY_PUBLIC_DOMAIN)

# Add manual allowed hosts from environment
manual_hosts = os.getenv('ALLOWED_HOSTS', 'localhost,127.0.0.1,0.0.0.0')
ALLOWED_HOSTS.extend([host.strip() for host in manual_hosts.split(',') if host.strip()])

print(f"   Allowed Hosts: {ALLOWED_HOSTS}")

# Database Configuration for Railway
DATABASE_URL = os.getenv('DATABASE_URL')
if DATABASE_URL:
    DATABASES = {
        'default': dj_database_url.parse(DATABASE_URL, conn_max_age=60)
    }
    # Add SSL requirement for Railway PostgreSQL
    DATABASES['default']['OPTIONS'] = {
        'sslmode': 'require',
    }
    print(f"✅ Database configured with Railway PostgreSQL")
else:
    print("❌ WARNING: DATABASE_URL not found!")

# Static Files Configuration
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Media Files
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# CORS Configuration
CORS_ALLOWED_ORIGINS = os.getenv('CORS_ALLOWED_ORIGINS', 'http://localhost:3000').split(',')
CORS_ALLOW_ALL_ORIGINS = os.getenv('CORS_ALLOW_ALL_ORIGINS', 'False').lower() == 'true'
CORS_ALLOW_CREDENTIALS = True

# Security Headers for Railway
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_SSL_REDIRECT = not DEBUG
SESSION_COOKIE_SECURE = not DEBUG
CSRF_COOKIE_SECURE = not DEBUG
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True

# Analysis Service Configuration
ANALYSIS_ENVIRONMENT = os.getenv('ANALYSIS_ENVIRONMENT', 'huggingface')

# Hugging Face Configuration
HUGGINGFACE_API_TOKEN = os.getenv('HUGGINGFACE_API_TOKEN')
HUGGINGFACE_MODEL_ID = os.getenv('HUGGINGFACE_MODEL_ID', 'mistralai/Mistral-7B-Instruct-v0.1')
HUGGINGFACE_TIMEOUT = int(os.getenv('HUGGINGFACE_TIMEOUT', '60'))
HUGGINGFACE_MAX_RETRIES = int(os.getenv('HUGGINGFACE_MAX_RETRIES', '3'))

if HUGGINGFACE_API_TOKEN:
    print(f"✅ Hugging Face API token configured")
else:
    print(f"⚠️ WARNING: HUGGINGFACE_API_TOKEN not set - AI features may not work")

# Disable heavy features for Railway
ENABLE_OCR = os.getenv('ENABLE_OCR', 'False').lower() == 'true'
ENABLE_OPENCV = os.getenv('ENABLE_OPENCV', 'False').lower() == 'true'
OCR_SERVICE = os.getenv('OCR_SERVICE', 'api')

print(f"   OCR Enabled: {ENABLE_OCR}")
print(f"   OpenCV Enabled: {ENABLE_OPENCV}")

# Logging Configuration
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'ipc_analysis': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}

# Cache Configuration (use database cache for simplicity)
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.db.DatabaseCache',
        'LOCATION': 'django_cache_table',
    }
}

# Email Configuration
EMAIL_BACKEND = os.getenv('EMAIL_BACKEND', 'django.core.mail.backends.console.EmailBackend')

# Legal Analysis Settings
MAX_CASE_DESCRIPTION_LENGTH = int(os.getenv('MAX_CASE_DESCRIPTION_LENGTH', '5000'))
ANALYSIS_HISTORY_RETENTION_DAYS = int(os.getenv('ANALYSIS_HISTORY_RETENTION_DAYS', '365'))

print(f"🎯 Railway settings configuration complete!")
