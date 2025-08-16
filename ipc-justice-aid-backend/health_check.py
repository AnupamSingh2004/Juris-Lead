"""
Production Health Check for Railway
Simple health check endpoint that verifies the service is running
"""

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from datetime import datetime
import os

@csrf_exempt
@require_http_methods(["GET"])
def health_check(request):
    """
    Simple health check endpoint for Railway
    Returns 200 OK if the service is running properly
    """
    
    # Basic health information
    health_info = {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "service": "IPC Justice Aid Backend",
        "version": "1.0.0",
        "environment": "production" if not os.getenv('DEBUG', 'False').lower() == 'true' else "development"
    }
    
    # Optional: Add database check
    try:
        from django.db import connection
        cursor = connection.cursor()
        cursor.execute("SELECT 1")
        health_info["database"] = "connected"
    except Exception:
        health_info["database"] = "disconnected"
        health_info["status"] = "degraded"
    
    # Return appropriate status code
    status_code = 200 if health_info["status"] in ["healthy", "degraded"] else 503
    
    return JsonResponse(health_info, status=status_code)
