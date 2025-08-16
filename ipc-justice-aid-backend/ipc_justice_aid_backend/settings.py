import os
from datetime import timedelta
from pathlib import Path
import dj_database_url

from decouple import config

BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.getenv('SECRET_KEY') or config('SECRET_KEY', default='django-insecure-development-key')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.getenv('DEBUG', 'False').lower() == 'true' or config('DEBUG', default=False, cast=bool)

# Get allowed hosts from environment or config
allowed_hosts_env = os.getenv('ALLOWED_HOSTS', '')
if allowed_hosts_env:
    ALLOWED_HOSTS = [host.strip() for host in allowed_hosts_env.split(',')]
else:
    ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='localhost,127.0.0.1,0.0.0.0,10.0.2.2,192.168.12.1,192.168.165.1,192.168.122.1,192.168.1.6').split(',')

# Azure App Service specific settings
AZURE_APP_SERVICE = os.getenv('AZURE_APP_SERVICE', 'False').lower() == 'true' or config('AZURE_APP_SERVICE', default=False, cast=bool)

if AZURE_APP_SERVICE:
    # Add Azure App Service domain to allowed hosts
    AZURE_DOMAIN = os.getenv('AZURE_DOMAIN') or config('AZURE_DOMAIN', default='')
    if AZURE_DOMAIN:
        ALLOWED_HOSTS.append(AZURE_DOMAIN)
        ALLOWED_HOSTS.append(f"{AZURE_DOMAIN}.azurewebsites.net")
    
    # Always add the Azure websites domain
    ALLOWED_HOSTS.extend([
        'ipc-justice-aid-api-india.azurewebsites.net',
        '.azurewebsites.net'
    ])

# Application definition
DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.sites',
]

THIRD_PARTY_APPS = [
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'oauth2_provider',
    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    'allauth.socialaccount.providers.google',
    'django_extensions',
    'django_celery_beat',
    'django_celery_results',
]

LOCAL_APPS = [
    'authentication',
    'ipc_analysis',
    'leads',
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # Added for static files in production
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'allauth.account.middleware.AccountMiddleware',  # Added this line
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'oauth2_provider.middleware.OAuth2TokenMiddleware',
]

ROOT_URLCONF = 'ipc_justice_aid_backend.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'ipc_justice_aid_backend.wsgi.application'

# Database configuration - supports both local Docker and Heroku
DATABASE_URL = os.getenv('DATABASE_URL')

if DATABASE_URL:
    # Production (Heroku) - Use DATABASE_URL provided by Heroku Postgres
    DATABASES = {
        'default': dj_database_url.parse(DATABASE_URL)
    }
else:
    # Local Development - Use Docker PostgreSQL with individual variables
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': config('DATABASE_NAME'),
            'USER': config('DATABASE_USER'),
            'PASSWORD': config('DATABASE_PASSWORD'),
            'HOST': config('DATABASE_HOST', default='localhost'),
            'PORT': config('DATABASE_PORT', default='5432'),
            'OPTIONS': {
                'sslmode': config('DATABASE_SSL_MODE', default='prefer'),
            } if not DEBUG else {},
        }
    }

# Custom User Model
AUTH_USER_MODEL = 'authentication.User'

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization - India specific
LANGUAGE_CODE = config('LANGUAGE_CODE', default='en-in')
TIME_ZONE = config('TIME_ZONE', default='Asia/Kolkata')
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'  # Changed for Azure compatibility

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Azure Blob Storage for static and media files (optional but recommended)
USE_AZURE_STORAGE = config('USE_AZURE_STORAGE', default=False, cast=bool)

if USE_AZURE_STORAGE:
    AZURE_ACCOUNT_NAME = config('AZURE_ACCOUNT_NAME')
    AZURE_ACCOUNT_KEY = config('AZURE_ACCOUNT_KEY')
    AZURE_CONTAINER = config('AZURE_CONTAINER', default='media')
    AZURE_STATIC_CONTAINER = config('AZURE_STATIC_CONTAINER', default='static')
    
    # Azure Storage settings for media files
    DEFAULT_FILE_STORAGE = 'storages.backends.azure_storage.AzureStorage'
    AZURE_STORAGE_ACCOUNT_NAME = AZURE_ACCOUNT_NAME
    AZURE_STORAGE_ACCOUNT_KEY = AZURE_ACCOUNT_KEY
    AZURE_STORAGE_CONTAINER = AZURE_CONTAINER
    
    # Azure Storage settings for static files
    STATICFILES_STORAGE = 'storages.backends.azure_storage.AzureStorage'
    AZURE_STATIC_STORAGE_ACCOUNT_NAME = AZURE_ACCOUNT_NAME
    AZURE_STATIC_STORAGE_ACCOUNT_KEY = AZURE_ACCOUNT_KEY
    AZURE_STATIC_STORAGE_CONTAINER = AZURE_STATIC_CONTAINER
else:
    # Use WhiteNoise for static files when not using Azure Storage
    STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# WhiteNoise configuration
WHITENOISE_USE_FINDERS = True
WHITENOISE_AUTOREFRESH = DEBUG

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Django REST Framework
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
        'oauth2_provider.contrib.rest_framework.OAuth2Authentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle'
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/hour',
        'user': '1000/hour'
    }
}

# Simple JWT
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=1),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': False,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'VERIFYING_KEY': None,
    'AUDIENCE': None,
    'ISSUER': None,
    'JWK_URL': None,
    'LEEWAY': 0,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'USER_AUTHENTICATION_RULE': 'rest_framework_simplejwt.authentication.default_user_authentication_rule',
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',
    'TOKEN_USER_CLASS': 'rest_framework_simplejwt.models.TokenUser',
    'JTI_CLAIM': 'jti',
    'SLIDING_TOKEN_REFRESH_EXP_CLAIM': 'refresh_exp',
    'SLIDING_TOKEN_LIFETIME': timedelta(minutes=5),
    'SLIDING_TOKEN_REFRESH_LIFETIME': timedelta(days=1),
}

# CORS Settings - Production ready
CORS_ALLOWED_ORIGINS = config('CORS_ALLOWED_ORIGINS', default='').split(',') if not DEBUG else [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://10.0.2.2:8000",  # Android emulator
    "http://localhost:8000",
    "http://127.0.0.1:8000",
    "http://192.168.165.1:8000",  # Current host IP
    "http://192.168.165.1:3000",  # Frontend on host IP
    # Flutter/Dart specific origins
    "http://localhost:50000",
    "http://127.0.0.1:50000",
    # Additional mobile origins
    "http://10.0.2.2:3000",
    "http://10.0.2.2:50000",
    # Add more IP ranges for mobile devices
    "http://192.168.0.0:8000",
    "http://192.168.1.0:8000",
]

# Add Azure domain to CORS if in production
if AZURE_APP_SERVICE and config('AZURE_DOMAIN', default=''):
    azure_domain = config('AZURE_DOMAIN')
    CORS_ALLOWED_ORIGINS.extend([
        f"https://{azure_domain}.azurewebsites.net",
        f"https://{azure_domain}",
    ])

CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_ALL_ORIGINS = DEBUG  # Only for development

# CSRF Settings - Production ready
CSRF_COOKIE_SECURE = not DEBUG  # Use secure cookies in production
CSRF_COOKIE_HTTPONLY = False
CSRF_COOKIE_SAMESITE = 'Lax'
CSRF_USE_SESSIONS = False
CSRF_COOKIE_NAME = 'csrftoken'

# CSRF Trusted Origins - Production ready
CSRF_TRUSTED_ORIGINS = config('CSRF_TRUSTED_ORIGINS', default='').split(',') if not DEBUG else [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://10.0.2.2:8000",
    "http://localhost:8000",
    "http://127.0.0.1:8000",
    "http://192.168.1.6:8000",
    "http://192.168.1.6:3000",
]

# Add Azure domain to CSRF trusted origins if in production
if AZURE_APP_SERVICE and config('AZURE_DOMAIN', default=''):
    azure_domain = config('AZURE_DOMAIN')
    CSRF_TRUSTED_ORIGINS.extend([
        f"https://{azure_domain}.azurewebsites.net",
        f"https://{azure_domain}",
    ])

# Additional CORS settings for mobile apps
CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
    'cache-control',
    'pragma',
]

CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]

# Email Configuration
EMAIL_BACKEND = config('EMAIL_BACKEND', default='django.core.mail.backends.console.EmailBackend')
EMAIL_HOST = config('EMAIL_HOST', default='')
EMAIL_PORT = config('EMAIL_PORT', default=587, cast=int)
EMAIL_USE_TLS = config('EMAIL_USE_TLS', default=True, cast=bool)
EMAIL_HOST_USER = config('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default='')
DEFAULT_FROM_EMAIL = config('DEFAULT_FROM_EMAIL', default='noreply@medicare.com')

# Google OAuth2
GOOGLE_OAUTH2_CLIENT_ID = config('GOOGLE_OAUTH2_CLIENT_ID', default='')
GOOGLE_OAUTH2_CLIENT_SECRET = config('GOOGLE_OAUTH2_CLIENT_SECRET', default='')

# Django Allauth
SITE_ID = 1
ACCOUNT_EMAIL_REQUIRED = True
ACCOUNT_USERNAME_REQUIRED = False
ACCOUNT_AUTHENTICATION_METHOD = 'email'
ACCOUNT_EMAIL_VERIFICATION = 'none'  # We handle email verification with OTP

SOCIALACCOUNT_PROVIDERS = {
    'google': {
        'SCOPE': [
            'profile',
            'email',
        ],
        'AUTH_PARAMS': {
            'access_type': 'online',
        },
        'OAUTH_PKCE_ENABLED': True,
        'APP': {
            'client_id': GOOGLE_OAUTH2_CLIENT_ID,
            'secret': GOOGLE_OAUTH2_CLIENT_SECRET,
        }
    }
}

# Redis Configuration
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': config('REDIS_URL', default='redis://redis:6379/0'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

# Security Settings
if not DEBUG:
    SECURE_BROWSER_XSS_FILTER = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    X_FRAME_OPTIONS = 'DENY'
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    SECURE_SSL_REDIRECT = True
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True

# Custom Settings
OTP_EXPIRY_MINUTES = config('OTP_EXPIRY_MINUTES', default=10, cast=int)
OTP_LENGTH = config('OTP_LENGTH', default=6, cast=int)

# India-specific optimizations
INDIA_SPECIFIC_SETTINGS = {
    'MOBILE_NETWORK_OPTIMIZATION': True,
    'LOW_BANDWIDTH_MODE': config('LOW_BANDWIDTH_MODE', default=True, cast=bool),
    'REGIONAL_CDN': config('REGIONAL_CDN', default=True, cast=bool),
    'IST_TIMEZONE_SUPPORT': True,
}

# Mobile network optimization for India
if INDIA_SPECIFIC_SETTINGS['MOBILE_NETWORK_OPTIMIZATION']:
    # Reduce timeout for mobile networks
    REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'] = {
        'anon': '200/hour',  # Increased for mobile users
        'user': '2000/hour'  # Increased for mobile users
    }
    
    # Enable compression for mobile networks
    MIDDLEWARE.insert(1, 'django.middleware.gzip.GZipMiddleware')

# Low bandwidth mode for rural areas
if INDIA_SPECIFIC_SETTINGS['LOW_BANDWIDTH_MODE']:
    # Compress responses
    USE_GZIP = True
    # Reduce image quality for mobile
    THUMBNAIL_QUALITY = 75
    # Cache more aggressively
    CACHE_MIDDLEWARE_SECONDS = 300

# IPC Justice Aid specific settings
OLLAMA_SETTINGS = {
    'BASE_URL': config('OLLAMA_BASE_URL', default='http://localhost:11434'),
    'MODEL_NAME': config('OLLAMA_MODEL_NAME', default='Anupam/IPC-Helper:latest'),
    'TIMEOUT': config('OLLAMA_TIMEOUT', default=30, cast=int),
    'MAX_RETRIES': config('OLLAMA_MAX_RETRIES', default=3, cast=int),
}

# Add Ollama settings as direct attributes for easier access
OLLAMA_BASE_URL = OLLAMA_SETTINGS['BASE_URL']
OLLAMA_MODEL_NAME = OLLAMA_SETTINGS['MODEL_NAME']
OLLAMA_TIMEOUT = OLLAMA_SETTINGS['TIMEOUT']
OLLAMA_MAX_RETRIES = OLLAMA_SETTINGS['MAX_RETRIES']

# Hugging Face settings for production deployment
HUGGINGFACE_SETTINGS = {
    'API_TOKEN': config('HUGGINGFACE_API_TOKEN', default=None),
    'MODEL_ID': config('HUGGINGFACE_MODEL_ID', default='mistralai/Mistral-7B-Instruct-v0.1'),
    'TIMEOUT': config('HUGGINGFACE_TIMEOUT', default=60, cast=int),
    'MAX_RETRIES': config('HUGGINGFACE_MAX_RETRIES', default=3, cast=int),
}

# Add Hugging Face settings as direct attributes for easier access
HUGGINGFACE_API_TOKEN = HUGGINGFACE_SETTINGS['API_TOKEN']
HUGGINGFACE_MODEL_ID = HUGGINGFACE_SETTINGS['MODEL_ID']
HUGGINGFACE_TIMEOUT = HUGGINGFACE_SETTINGS['TIMEOUT']
HUGGINGFACE_MAX_RETRIES = HUGGINGFACE_SETTINGS['MAX_RETRIES']

# Analysis service configuration
# Options: 'auto', 'ollama', 'huggingface'
# 'auto' will choose based on environment (dev=ollama, prod=huggingface)
ANALYSIS_ENVIRONMENT = config('ANALYSIS_ENVIRONMENT', default='auto')

# Legal analysis settings
LEGAL_ANALYSIS_SETTINGS = {
    'MAX_CASE_DESCRIPTION_LENGTH': config('MAX_CASE_DESCRIPTION_LENGTH', default=5000, cast=int),
    'ANALYSIS_HISTORY_RETENTION_DAYS': config('ANALYSIS_HISTORY_RETENTION_DAYS', default=365, cast=int),
    'ALLOW_ANONYMOUS_ANALYSIS': config('ALLOW_ANONYMOUS_ANALYSIS', default=True, cast=bool),
    'ENABLE_CASE_SHARING': config('ENABLE_CASE_SHARING', default=True, cast=bool),
}

# Lead management settings
LEAD_SETTINGS = {
    'DEFAULT_LEAD_EXPIRY_DAYS': config('DEFAULT_LEAD_EXPIRY_DAYS', default=30, cast=int),
    'MAX_LEADS_PER_LAWYER_PER_DAY': config('MAX_LEADS_PER_LAWYER_PER_DAY', default=10, cast=int),
    'AUTO_ASSIGN_LEADS': config('AUTO_ASSIGN_LEADS', default=True, cast=bool),
}

# Celery Configuration
CELERY_BROKER_URL = config('CELERY_BROKER_URL', default='redis://localhost:6379/0')
CELERY_RESULT_BACKEND = config('CELERY_RESULT_BACKEND', default='redis://localhost:6379/0')
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = TIME_ZONE
CELERY_BEAT_SCHEDULER = 'django_celery_beat.schedulers:DatabaseScheduler'

# Celery Beat Schedule
CELERY_BEAT_SCHEDULE = {
    'cleanup-expired-leads': {
        'task': 'leads.tasks.cleanup_expired_leads',
        'schedule': 3600.0,  # Every hour
    },
    'reset-monthly-limits': {
        'task': 'leads.tasks.reset_monthly_subscription_limits',
        'schedule': 86400.0 * 30,  # Monthly
    },
    'generate-analytics-report': {
        'task': 'leads.tasks.generate_analytics_report',
        'schedule': 86400.0,  # Daily
    },
    'update-lead-analytics': {
        'task': 'leads.tasks.update_lead_analytics',
        'schedule': 1800.0,  # Every 30 minutes
    },
}

# Payment Gateway Settings
RAZORPAY_KEY_ID = config('RAZORPAY_KEY_ID', default='')
RAZORPAY_KEY_SECRET = config('RAZORPAY_KEY_SECRET', default='')

STRIPE_PUBLISHABLE_KEY = config('STRIPE_PUBLISHABLE_KEY', default='')
STRIPE_SECRET_KEY = config('STRIPE_SECRET_KEY', default='')

# Frontend URL for email links
FRONTEND_URL = config('FRONTEND_URL', default='http://localhost:3000')

# Email settings for notifications
DEFAULT_FROM_EMAIL = config('DEFAULT_FROM_EMAIL', default='noreply@ipc-justice-aid.com')
ADMIN_EMAIL = config('ADMIN_EMAIL', default='')

# Additional settings for the Juris-Lead platform
JURIS_LEAD_SETTINGS = {
    'ENABLE_PRO_BONO_TIER': config('ENABLE_PRO_BONO_TIER', default=True, cast=bool),
    'MAX_FREE_ANALYSES_PER_IP': config('MAX_FREE_ANALYSES_PER_IP', default=5, cast=int),
    'REQUIRE_PHONE_VERIFICATION': config('REQUIRE_PHONE_VERIFICATION', default=False, cast=bool),
    'ENABLE_PDF_REPORTS': config('ENABLE_PDF_REPORTS', default=True, cast=bool),
}
OLLAMA_BASE_URL = OLLAMA_SETTINGS['BASE_URL']
OLLAMA_MODEL_NAME = OLLAMA_SETTINGS['MODEL_NAME']
OLLAMA_TIMEOUT = OLLAMA_SETTINGS['TIMEOUT']

# Logging Configuration
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
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
        'leads': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'leads.services': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'leads.views': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}