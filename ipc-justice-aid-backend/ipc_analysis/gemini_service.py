import requests
import json
import time
import re
from django.conf import settings
from typing import Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)


class GeminiService:
    """Service class to interact with Google Gemini API for IPC analysis"""
    
    def __init__(self):
        self.api_key = getattr(settings, 'GEMINI_API_KEY', None)
        self.model_name = getattr(settings, 'GEMINI_MODEL', 'gemini-1.5-flash')  # or 'gemini-1.5-pro'
        self.api_url = f"https://generativelanguage.googleapis.com/v1beta/models/{self.model_name}:generateContent"
        self.timeout = getattr(settings, 'GEMINI_TIMEOUT', 60)
        self.max_retries = getattr(settings, 'GEMINI_MAX_RETRIES', 3)
        
        # Available Gemini models:
        # - gemini-1.5-flash: Faster, good for most tasks
        # - gemini-1.5-pro: More capable, better for complex analysis
        # - gemini-1.0-pro: Earlier version, stable
        
        self.headers = {
            "Content-Type": "application/json"
        }
    
    def analyze_case(self, case_description: str) -> Dict[str, Any]:
        """
        Send case description to Gemini API and get IPC analysis
        
        Args:
            case_description (str): The legal case description
            
        Returns:
            Dict containing the analysis response and metadata
        """
        if not self.api_key:
            return self._get_error_response("Gemini API key not configured")
        
        prompt = self._create_legal_prompt(case_description)
        start_time = time.time()
        
        try:
            response = self._call_gemini_api(prompt)
            end_time = time.time()
            
            response_time_ms = int((end_time - start_time) * 1000)
            
            # Parse the response from Gemini
            analysis_result = self._parse_legal_response(response, case_description)
            
            return {
                'success': True,
                'analysis': analysis_result,
                'response_time_ms': response_time_ms,
                'raw_response': response,
                'model_used': self.model_name,
                'error': None
            }
            
        except Exception as e:
            end_time = time.time()
            response_time_ms = int((end_time - start_time) * 1000)
            logger.error(f"Gemini API error: {str(e)}")
            
            return {
                'success': False,
                'analysis': None,
                'response_time_ms': response_time_ms,
                'raw_response': None,
                'model_used': self.model_name,
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
    
    def _call_gemini_api(self, prompt: str) -> str:
        """Make the actual API call to Gemini API"""
        # Gemini API request format
        payload = {
            "contents": [
                {
                    "parts": [
                        {
                            "text": prompt
                        }
                    ]
                }
            ],
            "generationConfig": {
                "temperature": 0.3,  # Low temperature for consistent legal analysis
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 1024,
                "stopSequences": []
            },
            "safetySettings": [
                {
                    "category": "HARM_CATEGORY_HARASSMENT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                },
                {
                    "category": "HARM_CATEGORY_HATE_SPEECH",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                },
                {
                    "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                },
                {
                    "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                }
            ]
        }
        
        # Add API key to URL
        url_with_key = f"{self.api_url}?key={self.api_key}"
        
        for attempt in range(self.max_retries):
            try:
                response = requests.post(
                    url_with_key,
                    headers=self.headers,
                    json=payload,
                    timeout=self.timeout
                )
                
                if response.status_code == 200:
                    result = response.json()
                    
                    # Extract text from Gemini response format
                    if 'candidates' in result and len(result['candidates']) > 0:
                        candidate = result['candidates'][0]
                        if 'content' in candidate and 'parts' in candidate['content']:
                            parts = candidate['content']['parts']
                            if len(parts) > 0 and 'text' in parts[0]:
                                return parts[0]['text']
                    
                    # Fallback to raw response if structure is unexpected
                    return str(result)
                
                elif response.status_code == 429:
                    # Rate limit, wait and retry
                    if attempt < self.max_retries - 1:
                        wait_time = (2 ** attempt) * 2  # Exponential backoff starting at 2s
                        logger.info(f"Rate limited, waiting {wait_time}s before retry...")
                        time.sleep(wait_time)
                        continue
                    else:
                        raise Exception("Rate limit exceeded after multiple retries")
                
                elif response.status_code == 400:
                    # Bad request - probably a prompt issue
                    error_details = response.json() if response.content else {}
                    raise Exception(f"Bad request: {error_details}")
                
                elif response.status_code == 403:
                    # Permission denied - API key issue
                    raise Exception("Permission denied - check your Gemini API key")
                
                else:
                    raise Exception(f"Gemini API error: {response.status_code} - {response.text}")
                    
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
        
        raise Exception("Failed to get response from Gemini API")
    
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
            'model_used': self.model_name,
            'error': error_message
        }
    
    def health_check(self) -> Dict[str, Any]:
        """Check if Gemini service is available"""
        if not self.api_key:
            return {
                'status': 'unhealthy',
                'error': 'API key not configured',
                'service': 'gemini'
            }
        
        try:
            # Simple test request
            test_payload = {
                "contents": [
                    {
                        "parts": [
                            {
                                "text": "Say 'Hello' to test the connection."
                            }
                        ]
                    }
                ],
                "generationConfig": {
                    "maxOutputTokens": 10
                }
            }
            
            url_with_key = f"{self.api_url}?key={self.api_key}"
            
            response = requests.post(
                url_with_key,
                headers=self.headers,
                json=test_payload,
                timeout=10
            )
            
            if response.status_code == 200:
                return {
                    'status': 'healthy',
                    'model_name': self.model_name,
                    'service': 'gemini'
                }
            else:
                return {
                    'status': 'unhealthy',
                    'error': f"HTTP {response.status_code}",
                    'service': 'gemini'
                }
                
        except Exception as e:
            return {
                'status': 'unhealthy',
                'error': str(e),
                'service': 'gemini'
            }
