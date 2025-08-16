"""
Debug Health Check for Railway
This will show detailed error information to help diagnose the issue
"""

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import traceback
import os
import sys
import json
from datetime import datetime

@csrf_exempt
@require_http_methods(["GET"])
def debug_health_check(request):
    """
    Comprehensive debug health check that shows:
    1. Environment variables
    2. Django setup status
    3. Database connection
    4. Import status
    5. Any errors encountered
    """
    debug_info = {
        "status": "checking",
        "timestamp": datetime.now().isoformat(),
        "python_version": sys.version,
        "environment": {},
        "django": {},
        "database": {},
        "imports": {},
        "errors": []
    }
    
    try:
        # Environment variables check
        env_vars = [
            'DATABASE_URL', 'SECRET_KEY', 'DEBUG', 'ALLOWED_HOSTS',
            'GOOGLE_CLIENT_ID', 'HUGGINGFACE_API_TOKEN', 'DJANGO_SETTINGS_MODULE'
        ]
        
        for var in env_vars:
            value = os.getenv(var, 'NOT_SET')
            # Mask sensitive data
            if 'SECRET' in var or 'TOKEN' in var or 'PASSWORD' in var:
                debug_info["environment"][var] = f"{value[:10]}..." if value != 'NOT_SET' else 'NOT_SET'
            else:
                debug_info["environment"][var] = value
                
        # Django settings check
        try:
            from django.conf import settings
            debug_info["django"]["settings_configured"] = settings.configured
            debug_info["django"]["debug"] = getattr(settings, 'DEBUG', 'unknown')
            debug_info["django"]["allowed_hosts"] = getattr(settings, 'ALLOWED_HOSTS', 'unknown')
            debug_info["django"]["databases"] = list(getattr(settings, 'DATABASES', {}).keys())
        except Exception as e:
            debug_info["django"]["error"] = str(e)
            debug_info["errors"].append(f"Django settings error: {e}")
        
        # Database connection check
        try:
            from django.db import connection
            cursor = connection.cursor()
            cursor.execute("SELECT 1")
            result = cursor.fetchone()
            debug_info["database"]["status"] = "connected"
            debug_info["database"]["result"] = result[0] if result else "no_result"
        except Exception as e:
            debug_info["database"]["status"] = "error"
            debug_info["database"]["error"] = str(e)
            debug_info["errors"].append(f"Database error: {e}")
        
        # Critical imports check
        import_tests = [
            ('django', 'django'),
            ('rest_framework', 'rest_framework'),
            ('authentication', 'authentication.models'),
            ('ipc_analysis', 'ipc_analysis.views'),
        ]
        
        for name, module_path in import_tests:
            try:
                __import__(module_path)
                debug_info["imports"][name] = "success"
            except Exception as e:
                debug_info["imports"][name] = f"error: {str(e)}"
                debug_info["errors"].append(f"Import error ({name}): {e}")
        
        # Overall status
        if len(debug_info["errors"]) == 0:
            debug_info["status"] = "healthy"
        else:
            debug_info["status"] = "unhealthy"
            
    except Exception as e:
        debug_info["status"] = "critical_error"
        debug_info["critical_error"] = str(e)
        debug_info["traceback"] = traceback.format_exc()
    
    # Return appropriate status code
    status_code = 200 if debug_info["status"] == "healthy" else 500
    
    return JsonResponse(debug_info, status=status_code, json_dumps_params={'indent': 2})
