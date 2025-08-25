import os
import logging
from typing import Dict, Any
from django.conf import settings

from .services import OllamaService
from .gemini_service import GeminiService

logger = logging.getLogger(__name__)


class AdaptiveAnalysisService:
    """
    Adaptive service that chooses between:
    - Gemini (production)
    - Ollama (development)
    based on environment configuration
    """
    
    def __init__(self):
        self.environment = getattr(settings, 'ANALYSIS_ENVIRONMENT', 'auto')
        self.service_priority = self._determine_service_priority()
        
        # Initialize services
        self.ollama_service = None
        self.gemini_service = None
        
        # Initialize primary service
        if self.service_priority['primary'] == 'gemini':
            logger.info("Initializing Gemini service for analysis")
            self.gemini_service = GeminiService()
        else:
            logger.info("Initializing Ollama service for analysis")
            self.ollama_service = OllamaService()
        
        # Initialize fallback services for production
        if self.service_priority['primary'] == 'gemini':
            if not self.ollama_service:
                try:
                    self.ollama_service = OllamaService()
                    logger.info("Ollama service initialized as local fallback")
                except Exception:
                    logger.warning("Could not initialize Ollama fallback service")
    
    def _determine_service_priority(self) -> Dict[str, str]:
        """Determine which service to use based on environment and availability"""
        
        # Explicit configuration
        if self.environment == 'gemini':
            return {'primary': 'gemini', 'fallback': 'ollama'}
        elif self.environment == 'ollama':
            return {'primary': 'ollama', 'fallback': None}
        
        # Auto-detection based on environment variables
        # Check for cloud deployment platforms
        heroku_indicators = [
            'DYNO',  # Heroku dyno identifier
            'PORT',  # Heroku assigns PORT
            'DATABASE_URL',  # Heroku Postgres
        ]
        
        is_heroku = any(os.getenv(var) for var in heroku_indicators)
        
        # Check for other cloud platforms
        is_cloud = any([
            os.getenv('RENDER'),  # Render
            os.getenv('VERCEL'),  # Vercel
            os.getenv('NETLIFY'),  # Netlify
            os.getenv('RAILWAY_ENVIRONMENT'),  # Railway
            is_heroku
        ])
        
        # Check API key availability
        has_gemini_key = bool(getattr(settings, 'GEMINI_API_KEY', None))
        
        # Check if we're in production mode
        is_production = not getattr(settings, 'DEBUG', False)
        
        # Decision logic - prioritize Gemini for production
        if is_cloud or is_production:
            if has_gemini_key:
                logger.info("Detected cloud/production environment with Gemini API key - using Gemini")
                return {'primary': 'gemini', 'fallback': 'ollama'}
            else:
                logger.warning("Cloud/production environment detected but no Gemini key - falling back to Ollama")
                return {'primary': 'ollama', 'fallback': None}
        else:
            logger.info("Detected development environment - using Ollama")
            return {'primary': 'ollama', 'fallback': None}
    
    def analyze_case(self, case_description: str) -> Dict[str, Any]:
        """
        Analyze legal case using the appropriate service with fallback support
        
        Args:
            case_description (str): The legal case description
            
        Returns:
            Dict containing the analysis response and metadata
        """
        primary_service = self.service_priority['primary']
        
        try:
            # Try primary service
            if primary_service == 'gemini' and self.gemini_service:
                logger.debug("Using Gemini service for analysis")
                result = self.gemini_service.analyze_case(case_description)
                result['service_used'] = 'gemini'
                return result
                
            elif primary_service == 'ollama' and self.ollama_service:
                logger.debug("Using Ollama service for analysis")
                result = self.ollama_service.analyze_case(case_description)
                result['service_used'] = 'ollama'
                return result
                
            else:
                # Primary service not available, try fallbacks
                raise Exception(f"Primary service '{primary_service}' not available")
                
        except Exception as e:
            logger.error(f"Error in primary analysis service ({primary_service}): {str(e)}")
            
            # Try fallback services
            if primary_service == 'gemini' and self.ollama_service:
                try:
                    logger.info("Gemini failed, trying Ollama fallback")
                    result = self.ollama_service.analyze_case(case_description)
                    result['service_used'] = 'ollama_fallback'
                    result['fallback_reason'] = str(e)
                    result['primary_service_failed'] = primary_service
                    return result
                except Exception as fallback_error:
                    logger.error(f"Ollama fallback also failed: {str(fallback_error)}")
            
            # All services failed
            return self._get_fallback_response(case_description, str(e))
    
    def _get_fallback_response(self, case_description: str, error_message: str) -> Dict[str, Any]:
        """Provide a basic fallback response when services fail"""
        return {
            'success': False,
            'analysis': {
                "sections_applied": [{
                    "section_number": "Error",
                    "description": "Analysis service unavailable",
                    "reason": f"Service error: {error_message}"
                }],
                "explanation": f"Unable to analyze case due to service error. Please try again later. Error: {error_message}",
                "analysis_method": "fallback",
                "confidence_level": "none"
            },
            'response_time_ms': 0,
            'raw_response': None,
            'service_used': 'fallback',
            'error': error_message
        }
    
    def health_check(self) -> Dict[str, Any]:
        """Check health of all available analysis services"""
        primary_service = self.service_priority['primary']
        health_data = {
            'primary': None,
            'fallbacks': [],
            'environment': self.environment,
            'service_priority': self.service_priority
        }
        
        try:
            # Check primary service
            if primary_service == 'gemini' and self.gemini_service:
                health_data['primary'] = self.gemini_service.health_check()
                health_data['primary']['primary_service'] = True
                
            elif primary_service == 'ollama' and self.ollama_service:
                health_data['primary'] = self.ollama_service.health_check()
                health_data['primary']['primary_service'] = True
            
            # Check fallback services
            fallback_services = [
                ('gemini', self.gemini_service),
                ('ollama', self.ollama_service)
            ]
            
            for service_name, service_instance in fallback_services:
                if service_name != primary_service and service_instance:
                    try:
                        fallback_health = service_instance.health_check()
                        fallback_health['primary_service'] = False
                        fallback_health['role'] = 'fallback'
                        health_data['fallbacks'].append(fallback_health)
                    except Exception as e:
                        health_data['fallbacks'].append({
                            'status': 'error',
                            'service': service_name,
                            'error': str(e),
                            'role': 'fallback'
                        })
            
            return health_data
                
        except Exception as e:
            return {
                'primary': {'status': 'error', 'error': str(e)},
                'fallbacks': [],
                'environment': self.environment,
                'service_priority': self.service_priority
            }
    
    def get_service_info(self) -> Dict[str, Any]:
        """Get information about the current service configuration"""
        return {
            'primary_service': self.service_priority['primary'],
            'fallback_service': self.service_priority.get('fallback'),
            'environment': self.environment,
            'services_available': {
                'gemini': self.gemini_service is not None,
                'ollama': self.ollama_service is not None
            },
            'debug_mode': getattr(settings, 'DEBUG', False),
            'service_priority': self.service_priority
        }


# Global instance - this will be imported by views
adaptive_analysis_service = AdaptiveAnalysisService()
