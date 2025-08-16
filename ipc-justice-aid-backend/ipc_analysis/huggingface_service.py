import requests
import json
import time
import re
from django.conf import settings
from typing import Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)


class HuggingFaceService:
    """Service class to interact with Hugging Face Inference API for IPC analysis"""
    
    def __init__(self):
        self.api_token = getattr(settings, 'HUGGINGFACE_API_TOKEN', None)
        # Use a better model for legal analysis - Mistral is better for instruction following
        self.model_id = getattr(settings, 'HUGGINGFACE_MODEL_ID', 'mistralai/Mistral-7B-Instruct-v0.1')
        self.api_url = f"https://api-inference.huggingface.co/models/{self.model_id}"
        self.timeout = getattr(settings, 'HUGGINGFACE_TIMEOUT', 60)
        self.max_retries = getattr(settings, 'HUGGINGFACE_MAX_RETRIES', 3)
        
        # Alternative models for legal analysis:
        # 1. mistralai/Mistral-7B-Instruct-v0.1 - Good for instruction following
        # 2. microsoft/DialoGPT-medium - Conversational AI
        # 3. google/flan-t5-large - Good for structured tasks
        # 4. nlpaueb/legal-bert-base-uncased - Legal domain specific (but smaller)
        
        self.headers = {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json"
        }
    
    def analyze_case(self, case_description: str) -> Dict[str, Any]:
        """
        Send case description to Hugging Face model and get IPC analysis
        
        Args:
            case_description (str): The legal case description
            
        Returns:
            Dict containing the analysis response and metadata
        """
        if not self.api_token:
            return self._get_error_response("Hugging Face API token not configured")
        
        prompt = self._create_legal_prompt(case_description)
        start_time = time.time()
        
        try:
            response = self._call_huggingface_api(prompt)
            end_time = time.time()
            
            response_time_ms = int((end_time - start_time) * 1000)
            
            # Parse the response from Hugging Face
            analysis_result = self._parse_legal_response(response, case_description)
            
            return {
                'success': True,
                'analysis': analysis_result,
                'response_time_ms': response_time_ms,
                'raw_response': response,
                'model_used': self.model_id,
                'error': None
            }
            
        except Exception as e:
            end_time = time.time()
            response_time_ms = int((end_time - start_time) * 1000)
            logger.error(f"Hugging Face API error: {str(e)}")
            
            return {
                'success': False,
                'analysis': None,
                'response_time_ms': response_time_ms,
                'raw_response': None,
                'model_used': self.model_id,
                'error': str(e)
            }
    
    def _create_legal_prompt(self, case_description: str) -> str:
        """Create a formatted prompt for legal analysis - matches Ollama service prompt exactly"""
        prompt = f"""
{case_description.strip()}

Which IPC sections will be applied in this case? Give response in JSON format with a description of those IPCs and why were those applied.

Please provide the response in the following JSON format:
{{
  "sections_applied": [
    {{
      "section_number": "304A",
      "description": "Brief description of the section",
      "reason": "Explanation of why this section applies to the case"
    }}
  ],
  "explanation": "Overall explanation of the legal analysis"
}}
"""
        return prompt
    
    def _call_huggingface_api(self, prompt: str) -> str:
        """Make the actual API call to Hugging Face Inference API"""
        payload = {
            "inputs": prompt,
            "parameters": {
                "max_new_tokens": 800,
                "temperature": 0.3,  # Lower temperature for more consistent JSON output
                "do_sample": True,
                "return_full_text": False,
                "stop": ["</s>", "<|endoftext|>"],  # Stop tokens to prevent overgeneration
                "repetition_penalty": 1.1
            },
            "options": {
                "wait_for_model": True,
                "use_cache": False
            }
        }
        
        for attempt in range(self.max_retries):
            try:
                response = requests.post(
                    self.api_url,
                    headers=self.headers,
                    json=payload,
                    timeout=self.timeout
                )
                
                if response.status_code == 200:
                    result = response.json()
                    
                    # Handle different response formats
                    if isinstance(result, list) and len(result) > 0:
                        return result[0].get('generated_text', str(result))
                    elif isinstance(result, dict):
                        return result.get('generated_text', str(result))
                    else:
                        return str(result)
                
                elif response.status_code == 503:
                    # Model loading, wait and retry
                    if attempt < self.max_retries - 1:
                        wait_time = 2 ** attempt  # Exponential backoff
                        logger.info(f"Model loading, waiting {wait_time}s before retry...")
                        time.sleep(wait_time)
                        continue
                    else:
                        raise Exception("Model is still loading after multiple retries")
                
                else:
                    raise Exception(f"Hugging Face API error: {response.status_code} - {response.text}")
                    
            except requests.exceptions.Timeout:
                if attempt < self.max_retries - 1:
                    logger.warning(f"Request timeout, retrying... (attempt {attempt + 1})")
                    continue
                else:
                    raise Exception("Request timeout after multiple retries")
            
            except requests.exceptions.RequestException as e:
                if attempt < self.max_retries - 1:
                    logger.warning(f"Request failed, retrying... (attempt {attempt + 1}): {str(e)}")
                    time.sleep(1)
                    continue
                else:
                    raise Exception(f"Request failed after multiple retries: {str(e)}")
        
        raise Exception("Failed to get response from Hugging Face API")
    
    def _parse_legal_response(self, response_text: str, original_case: str) -> Dict[str, Any]:
        """Parse the response using the same logic as Ollama service"""
        try:
            # Clean the response text
            cleaned_response = response_text.strip()
            
            # Try to parse as JSON directly (same as Ollama service)
            parsed = json.loads(cleaned_response)
            
            # Validate required fields (same as Ollama service)
            if 'sections_applied' not in parsed:
                raise ValueError("Missing 'sections_applied' in response")
            
            if 'explanation' not in parsed:
                parsed['explanation'] = "No explanation provided"
            
            return parsed
            
        except json.JSONDecodeError as e:
            # If direct parsing fails, try to extract JSON from text (same as Ollama service)
            return self._extract_json_from_text(response_text)
    
    def _extract_json_from_text(self, text: str) -> Dict[str, Any]:
        """Extract JSON from text response - same logic as Ollama service"""
        import re
        
        # Look for JSON patterns in the text (same as Ollama service)
        json_pattern = r'\{.*\}'
        match = re.search(json_pattern, text, re.DOTALL)
        
        if match:
            try:
                return json.loads(match.group())
            except json.JSONDecodeError:
                pass
        
        # Fallback: create a basic structure (same as Ollama service)
        return {
            "sections_applied": [
                {
                    "section_number": "Unknown",
                    "description": "Could not parse response",
                    "reason": "Response format error"
                }
            ],
            "explanation": f"Raw response: {text[:500]}..."
        }
    
    def _clean_response_text(self, text: str) -> str:
        """Clean and format the response text"""
        # Remove extra whitespace and formatting
        cleaned = re.sub(r'\s+', ' ', text.strip())
        
        # Limit length for storage
        if len(cleaned) > 1000:
            cleaned = cleaned[:1000] + "..."
        
        return cleaned
    
    def _get_error_response(self, error_message: str) -> Dict[str, Any]:
        """Return standardized error response"""
        return {
            'success': False,
            'analysis': {
                "sections_applied": [{
                    "section_number": "Error",
                    "description": "Analysis unavailable",
                    "reason": error_message
                }],
                "explanation": f"Error: {error_message}",
                "analysis_method": "error",
                "confidence_level": "none"
            },
            'response_time_ms': 0,
            'raw_response': None,
            'model_used': self.model_id,
            'error': error_message
        }
    
    def health_check(self) -> Dict[str, Any]:
        """Check if Hugging Face service is available"""
        if not self.api_token:
            return {
                'status': 'unhealthy',
                'error': 'API token not configured',
                'service': 'huggingface'
            }
        
        try:
            # Simple test request
            test_payload = {
                "inputs": "Test connection",
                "parameters": {"max_new_tokens": 10}
            }
            
            response = requests.post(
                self.api_url,
                headers=self.headers,
                json=test_payload,
                timeout=10
            )
            
            if response.status_code in [200, 503]:  # 503 means model loading
                return {
                    'status': 'healthy',
                    'model_id': self.model_id,
                    'service': 'huggingface',
                    'note': 'Model loading' if response.status_code == 503 else 'Ready'
                }
            else:
                return {
                    'status': 'unhealthy',
                    'error': f"HTTP {response.status_code}",
                    'service': 'huggingface'
                }
                
        except Exception as e:
            return {
                'status': 'unhealthy',
                'error': str(e),
                'service': 'huggingface'
            }
