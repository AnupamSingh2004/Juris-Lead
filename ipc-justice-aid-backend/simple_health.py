"""
Simple health check for Railway deployment
This creates a basic health endpoint that Railway can use
"""

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.db import connection
from django.conf import settings
import json

@csrf_exempt
@require_http_methods(["GET"])
def simple_health_check(request):
    """
    Simple health check that only verifies:
    1. Django is running
    2. Database connection works
    """
    try:
        # Test database connection
        cursor = connection.cursor()
        cursor.execute("SELECT 1")
        db_status = "connected"
    except Exception as e:
        db_status = f"error: {str(e)}"
    
    health_data = {
        "status": "ok",
        "database": db_status,
        "debug": settings.DEBUG,
        "message": "Juris-Lead API is running"
    }
    
    # Return 500 if database is not working
    if "error" in db_status:
        return JsonResponse(health_data, status=500)
    
    return JsonResponse(health_data)
