# Railway-specific settings
# This file contains settings optimized for Railway deployment

import os
from .settings import *

# Railway-specific environment variables
RAILWAY_ENVIRONMENT = os.getenv('RAILWAY_ENVIRONMENT')
RAILWAY_PUBLIC_DOMAIN = os.getenv('RAILWAY_PUBLIC_DOMAIN')

if RAILWAY_ENVIRONMENT:
    print(f"Running in Railway environment: {RAILWAY_ENVIRONMENT}")
    
    # Update allowed hosts for Railway
    if RAILWAY_PUBLIC_DOMAIN:
        ALLOWED_HOSTS = [RAILWAY_PUBLIC_DOMAIN, 'localhost', '127.0.0.1', '0.0.0.0']
    
    # Disable image processing features that require heavy dependencies
    ENABLE_OCR = False
    ENABLE_OPENCV = False
    
    # Use API-based image processing instead
    OCR_SERVICE = 'api'  # Use external OCR API instead of local tesseract
    
    # Optimize static files for Railway
    STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
    
    # Database optimization for Railway
    DATABASES['default']['CONN_MAX_AGE'] = 60
    DATABASES['default']['OPTIONS'] = {
        'sslmode': 'require',
    }
    
    # Logging configuration for Railway
    LOGGING = {
        'version': 1,
        'disable_existing_loggers': False,
        'handlers': {
            'console': {
                'class': 'logging.StreamHandler',
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
        },
    }
    
    # Railway-specific security settings
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
