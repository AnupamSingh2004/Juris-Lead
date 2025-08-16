
import logging
import json
from typing import Dict, Any, Optional
from .ocr_service import OCRService
from .services import OllamaService
import PyPDF2
import io

logger = logging.getLogger(__name__)


class DocumentSummarizerService:
    
    def __init__(self):
        self.ocr_service = OCRService()
        self.ollama_service = OllamaService()
    
    def summarize_document(self, file, file_type: str) -> Dict[str, Any]:
        """
        Summarize a document file
        
        Args:
            file: Django UploadedFile object
            file_type: Type of file (pdf, image, text)
            
        Returns:
            Dict containing summary and analysis
        """
        try:
            # Extract text from document
            if file_type == 'pdf':
                text_result = self._extract_text_from_pdf(file)
            elif file_type == 'image':
                text_result = self.ocr_service.extract_text_from_image(file)
            else:
                return {
                    'success': False,
                    'error': f'Unsupported file type: {file_type}'
                }
            
            if not text_result['success']:
                return text_result
            
            extracted_text = text_result['text']
            
            if not extracted_text.strip():
                return {
                    'success': False,
                    'error': 'No text content found in the document'
                }
            
            # Generate AI summary
            summary_result = self._generate_ai_summary(extracted_text)
            
            if not summary_result['success']:
                return summary_result
            
            return {
                'success': True,
                'summary': summary_result['summary'],
                'extracted_text': extracted_text,
                'word_count': len(extracted_text.split()),
                'character_count': len(extracted_text),
                'file_info': {
                    'name': file.name,
                    'size_mb': round(file.size / (1024 * 1024), 2),
                    'type': file_type
                }
            }
            
        except Exception as e:
            logger.error(f"Document summarization failed: {str(e)}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def _extract_text_from_pdf(self, pdf_file) -> Dict[str, Any]:
        """Extract text from PDF file"""
        try:
            pdf_data = pdf_file.read()
            pdf_file.seek(0)  # Reset file pointer
            
            # Use PyPDF2 for text extraction
            pdf_reader = PyPDF2.PdfReader(io.BytesIO(pdf_data))
            
            text_content = []
            page_count = len(pdf_reader.pages)
            
            for page_num, page in enumerate(pdf_reader.pages):
                try:
                    page_text = page.extract_text()
                    if page_text.strip():
                        text_content.append(page_text)
                except Exception as e:
                    logger.warning(f"Failed to extract text from page {page_num + 1}: {str(e)}")
            
            extracted_text = '\n'.join(text_content)
            
            return {
                'success': True,
                'text': extracted_text,
                'page_count': page_count
            }
            
        except Exception as e:
            logger.error(f"PDF text extraction failed: {str(e)}")
            return {
                'success': False,
                'error': f'Failed to extract text from PDF: {str(e)}',
                'text': ''
            }
    
    def _generate_ai_summary(self, text: str) -> Dict[str, Any]:
        """Generate AI summary of the document text"""
        try:
            # Create a specialized prompt for document summarization
            summary_prompt = f"""
You are an intelligent document analyzer. Please analyze the following document and provide a comprehensive summary in JSON format.

Document Text:
{text}

Please provide a summary in the following JSON structure:

{{
    "document_type": "Type of document (e.g., Report, Letter, Article, Manual, Contract, etc.)",
    "simple_summary": "A simple, easy-to-understand summary in 2-3 sentences",
    "detailed_summary": "A more detailed summary covering all important points",
    "key_points": [
        "List of key points from the document",
        "Each point should be clear and concise"
    ],
    "parties_involved": [
        "Names of people, organizations, or entities mentioned"
    ],
    "important_dates": [
        "Any dates mentioned in the document"
    ],
    "legal_implications": "Important implications or significance of this document",
    "action_required": "What actions, if any, are required or recommended based on this document",
    "urgency_level": "High/Medium/Low - based on time sensitivity and importance",
    "language_complexity": "Simple/Moderate/Complex - how difficult the language is"
}}

Make sure your response is valid JSON format. Use simple, clear language that anyone can understand.
"""

            # Call Ollama service
            ollama_result = self.ollama_service.analyze_case(summary_prompt)
            
            if not ollama_result['success']:
                return {
                    'success': False,
                    'error': f"AI summarization failed: {ollama_result['error']}"
                }
            
            # Parse the AI response
            ai_response = ollama_result['analysis']
            
            # Try to extract JSON from the response
            summary_json = self._extract_json_from_response(ai_response)
            
            if not summary_json:
                # If JSON parsing fails, create a simple summary
                summary_json = {
                    "document_type": "General Document",
                    "simple_summary": "Document analysis completed. Please review the detailed text for specific information.",
                    "detailed_summary": ai_response.get('explanation', 'AI analysis completed'),
                    "key_points": ["AI analysis provided", "Please review document carefully"],
                    "parties_involved": [],
                    "important_dates": [],
                    "legal_implications": "Document review recommended for important decisions",
                    "action_required": "Review document content and take appropriate action if needed",
                    "urgency_level": "Medium",
                    "language_complexity": "Moderate"
                }
            
            return {
                'success': True,
                'summary': summary_json,
                'raw_ai_response': ai_response
            }
            
        except Exception as e:
            logger.error(f"AI summary generation failed: {str(e)}")
            return {
                'success': False,
                'error': f'Failed to generate AI summary: {str(e)}'
            }
    
    def _extract_json_from_response(self, response: Any) -> Optional[Dict]:
        """Extract JSON from AI response"""
        try:
            # If response is already a dict with expected structure
            if isinstance(response, dict):
                if 'explanation' in response:
                    # Try to find JSON in explanation
                    explanation = response['explanation']
                    if isinstance(explanation, str):
                        return self._parse_json_from_string(explanation)
                return response
            
            # If response is a string, try to parse JSON
            if isinstance(response, str):
                return self._parse_json_from_string(response)
            
            return None
            
        except Exception as e:
            logger.warning(f"JSON extraction failed: {str(e)}")
            return None
    
    def _parse_json_from_string(self, text: str) -> Optional[Dict]:
        """Parse JSON from a string that might contain other text"""
        try:
            # First, try direct JSON parsing
            return json.loads(text)
        except:
            pass
        
        try:
            # Look for JSON blocks in the text
            import re
            json_pattern = r'\{.*?\}'
            matches = re.findall(json_pattern, text, re.DOTALL)
            
            for match in matches:
                try:
                    return json.loads(match)
                except:
                    continue
            
            return None
            
        except Exception as e:
            logger.warning(f"JSON parsing failed: {str(e)}")
            return None
    
    def validate_document_file(self, file, file_type: str) -> Dict[str, Any]:
        """Validate uploaded document file"""
        try:
            # Check file size (max 50MB for documents)
            max_size = 50 * 1024 * 1024  # 50MB
            if file.size > max_size:
                return {
                    'valid': False,
                    'error': 'File size exceeds 50MB limit'
                }
            
            # Check file format based on type
            if file_type == 'pdf':
                allowed_types = ['application/pdf']
            elif file_type == 'image':
                allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp']
            else:
                return {
                    'valid': False,
                    'error': f'Unsupported file type: {file_type}'
                }
            
            if file.content_type not in allowed_types:
                return {
                    'valid': False,
                    'error': f'Invalid file format. Expected: {", ".join(allowed_types)}'
                }
            
            return {
                'valid': True,
                'format': file.content_type,
                'size_mb': round(file.size / (1024 * 1024), 2)
            }
            
        except Exception as e:
            return {
                'valid': False,
                'error': f'File validation error: {str(e)}'
            }
