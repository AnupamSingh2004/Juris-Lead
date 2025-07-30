import requests
import json
import time
from django.conf import settings
from typing import Dict, Any, Optional


class OllamaService:
    """Service class to interact with Ollama API for IPC analysis"""
    
    def __init__(self):
        self.base_url = getattr(settings, 'OLLAMA_BASE_URL', 'http://localhost:11434')
        self.model_name = getattr(settings, 'OLLAMA_MODEL_NAME', 'Anupam/IPC-Helper:latest')
        self.timeout = getattr(settings, 'OLLAMA_TIMEOUT', 30)
    
    def analyze_case(self, case_description: str) -> Dict[str, Any]:
        """
        Send case description to Ollama model and get IPC analysis
        
        Args:
            case_description (str): The legal case description
            
        Returns:
            Dict containing the analysis response and metadata
        """
        prompt = self._create_prompt(case_description)
        
        start_time = time.time()
        
        try:
            response = self._call_ollama_api(prompt)
            end_time = time.time()
            
            response_time_ms = int((end_time - start_time) * 1000)
            
            # Parse the JSON response from Ollama
            analysis_result = self._parse_ollama_response(response)
            
            return {
                'success': True,
                'analysis': analysis_result,
                'response_time_ms': response_time_ms,
                'raw_response': response,
                'error': None
            }
            
        except Exception as e:
            end_time = time.time()
            response_time_ms = int((end_time - start_time) * 1000)
            
            return {
                'success': False,
                'analysis': None,
                'response_time_ms': response_time_ms,
                'raw_response': None,
                'error': str(e)
            }
    
    def _create_prompt(self, case_description: str) -> str:
        """Create a formatted prompt for the Ollama model"""
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
    
    def _call_ollama_api(self, prompt: str) -> str:
        """Make the actual API call to Ollama"""
        url = f"{self.base_url}/api/generate"
        
        payload = {
            "model": self.model_name,
            "prompt": prompt,
            "stream": False,
            "format": "json"
        }
        
        headers = {
            "Content-Type": "application/json"
        }
        
        response = requests.post(
            url, 
            json=payload, 
            headers=headers, 
            timeout=self.timeout
        )
        
        if response.status_code != 200:
            raise Exception(f"Ollama API error: {response.status_code} - {response.text}")
        
        result = response.json()
        
        if 'response' not in result:
            raise Exception("Invalid response format from Ollama API")
        
        return result['response']
    
    def _parse_ollama_response(self, response_text: str) -> Dict[str, Any]:
        """Parse the JSON response from Ollama"""
        try:
            # Try to parse as JSON directly
            parsed = json.loads(response_text)
            
            # Validate required fields
            if 'sections_applied' not in parsed:
                raise ValueError("Missing 'sections_applied' in response")
            
            if 'explanation' not in parsed:
                parsed['explanation'] = "No explanation provided"
            
            return parsed
            
        except json.JSONDecodeError as e:
            # If direct parsing fails, try to extract JSON from text
            return self._extract_json_from_text(response_text)
    
    def _extract_json_from_text(self, text: str) -> Dict[str, Any]:
        """Extract JSON from text response that might have additional formatting"""
        import re
        
        # Look for JSON patterns in the text
        json_pattern = r'\{.*\}'
        match = re.search(json_pattern, text, re.DOTALL)
        
        if match:
            try:
                return json.loads(match.group())
            except json.JSONDecodeError:
                pass
        
        # Fallback: create a basic structure
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
    
    def health_check(self) -> Dict[str, Any]:
        """Check if Ollama service is available"""
        try:
            url = f"{self.base_url}/api/tags"
            response = requests.get(url, timeout=5)
            
            if response.status_code == 200:
                models = response.json().get('models', [])
                model_available = any(
                    model.get('name') == self.model_name 
                    for model in models
                )
                
                return {
                    'status': 'healthy',
                    'model_available': model_available,
                    'available_models': [m.get('name') for m in models]
                }
            else:
                return {
                    'status': 'unhealthy',
                    'error': f"HTTP {response.status_code}"
                }
                
        except Exception as e:
            return {
                'status': 'unhealthy',
                'error': str(e)
            }
