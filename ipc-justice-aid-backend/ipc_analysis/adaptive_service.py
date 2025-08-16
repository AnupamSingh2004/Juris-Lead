import os
import logging
from typing import Dict, Any
from django.conf import settings

from .services import OllamaService
from .huggingface_service import HuggingFaceService

logger = logging.getLogger(__name__)


class AdaptiveAnalysisService:
    """
    Adaptive service that chooses between Ollama (development) and Hugging Face (production)
    based on environment configuration
    """
    
    def __init__(self):
        self.environment = getattr(settings, 'ANALYSIS_ENVIRONMENT', 'auto')
        self.use_huggingface = self._should_use_huggingface()
        
        # Initialize services
        self.ollama_service = None
        self.huggingface_service = None
        
        if self.use_huggingface:
            logger.info("Initializing Hugging Face service for analysis")
            self.huggingface_service = HuggingFaceService()
        else:
            logger.info("Initializing Ollama service for analysis")
            self.ollama_service = OllamaService()
    
    def _should_use_huggingface(self) -> bool:
        """Determine which service to use based on environment"""
        
        # Explicit configuration
        if self.environment == 'huggingface':
            return True
        elif self.environment == 'ollama':
            return False
        
        # Auto-detection based on environment variables
        # Check for Heroku-specific environment variables
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
        
        # Check if Hugging Face token is available
        has_hf_token = bool(getattr(settings, 'HUGGINGFACE_API_TOKEN', None))
        
        # Check if we're in production mode
        is_production = not getattr(settings, 'DEBUG', False)
        
        # Decision logic
        if is_cloud or is_production:
            if has_hf_token:
                logger.info("Detected cloud/production environment with HF token - using Hugging Face")
                return True
            else:
                logger.warning("Cloud/production environment detected but no HF token - falling back to Ollama")
                return False
        else:
            logger.info("Detected development environment - using Ollama")
            return False
    
    def analyze_case(self, case_description: str) -> Dict[str, Any]:
        """
        Analyze legal case using the appropriate service
        
        Args:
            case_description (str): The legal case description
            
        Returns:
            Dict containing the analysis response and metadata
        """
        try:
            if self.use_huggingface and self.huggingface_service:
                logger.debug("Using Hugging Face service for analysis")
                result = self.huggingface_service.analyze_case(case_description)
                result['service_used'] = 'huggingface'
                return result
                
            elif self.ollama_service:
                logger.debug("Using Ollama service for analysis")
                result = self.ollama_service.analyze_case(case_description)
                result['service_used'] = 'ollama'
                return result
                
            else:
                # Fallback error
                return self._get_fallback_response(case_description, "No analysis service available")
                
        except Exception as e:
            logger.error(f"Error in adaptive analysis: {str(e)}")
            
            # Try fallback service if primary fails
            if self.use_huggingface and self.ollama_service:
                logger.info("Hugging Face failed, trying Ollama fallback")
                try:
                    result = self.ollama_service.analyze_case(case_description)
                    result['service_used'] = 'ollama_fallback'
                    result['fallback_reason'] = str(e)
                    return result
                except Exception as fallback_error:
                    logger.error(f"Fallback also failed: {str(fallback_error)}")
            
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
        """Check health of the current analysis service"""
        try:
            if self.use_huggingface and self.huggingface_service:
                hf_health = self.huggingface_service.health_check()
                hf_health['primary_service'] = True
                
                # Also check Ollama if available for fallback info
                ollama_health = None
                if self.ollama_service:
                    try:
                        ollama_health = self.ollama_service.health_check()
                        ollama_health['primary_service'] = False
                        ollama_health['role'] = 'fallback'
                    except:
                        ollama_health = {'status': 'unavailable', 'role': 'fallback'}
                
                return {
                    'primary': hf_health,
                    'fallback': ollama_health,
                    'environment': self.environment,
                    'auto_detected': self.use_huggingface
                }
                
            elif self.ollama_service:
                ollama_health = self.ollama_service.health_check()
                ollama_health['primary_service'] = True
                
                return {
                    'primary': ollama_health,
                    'fallback': None,
                    'environment': self.environment,
                    'auto_detected': not self.use_huggingface
                }
            
            else:
                return {
                    'primary': {'status': 'unhealthy', 'error': 'No service initialized'},
                    'fallback': None,
                    'environment': self.environment,
                    'auto_detected': self.use_huggingface
                }
                
        except Exception as e:
            return {
                'primary': {'status': 'error', 'error': str(e)},
                'fallback': None,
                'environment': self.environment,
                'auto_detected': self.use_huggingface
            }
    
    def get_service_info(self) -> Dict[str, Any]:
        """Get information about the current service configuration"""
        return {
            'using_huggingface': self.use_huggingface,
            'environment': self.environment,
            'huggingface_available': self.huggingface_service is not None,
            'ollama_available': self.ollama_service is not None,
            'debug_mode': getattr(settings, 'DEBUG', False),
            'primary_service': 'huggingface' if self.use_huggingface else 'ollama'
        }


# Global instance - this will be imported by views
adaptive_analysis_service = AdaptiveAnalysisService()
