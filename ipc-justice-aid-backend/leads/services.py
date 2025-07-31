import requests
import json
import logging
from datetime import datetime, timedelta
from django.conf import settings
from django.utils import timezone
from typing import Dict, List, Optional, Tuple
import re

logger = logging.getLogger(__name__)


class OllamaIPCService:
    """Service to interact with the local Ollama IPC-Helper model"""
    
    def __init__(self):
        self.base_url = getattr(settings, 'OLLAMA_BASE_URL', 'http://ollama:11434')
        self.model_name = getattr(settings, 'OLLAMA_MODEL_NAME', 'Anupam/IPC-Helper:latest')
        self.timeout = getattr(settings, 'OLLAMA_TIMEOUT', 300)  # 5 minutes for model responses
        self.max_retries = getattr(settings, 'OLLAMA_MAX_RETRIES', 2)
        logger.info(f"OllamaIPCService initialized with URL: {self.base_url}, Timeout: {self.timeout}s")
    
    def analyze_case(self, case_description: str, incident_date: Optional[str] = None, 
                    location: Optional[str] = None) -> Dict:
        """
        Analyze a legal case using the IPC-Helper model
        
        Args:
            case_description: The incident description from the user
            incident_date: Optional date of incident
            location: Optional location of incident
            
        Returns:
            Dict containing the analysis results
        """
        try:
            # Construct the prompt similar to your example
            prompt = self._construct_analysis_prompt(case_description, incident_date, location)
            
            # Make request to Ollama
            response = self._make_ollama_request(prompt)
            
            # Parse the JSON response
            analysis = self._parse_ollama_response(response)
            
            # Enhance the analysis with additional processing
            enhanced_analysis = self._enhance_analysis(analysis)
            
            return enhanced_analysis
            
        except ConnectionError as e:
            logger.error(f"Connection error during case analysis: {str(e)}")
            return self._get_connection_error_fallback(case_description)
        except Exception as e:
            logger.error(f"Error in case analysis: {str(e)}", exc_info=True)
            return self._get_fallback_analysis(case_description)
    
    def _construct_analysis_prompt(self, case_description: str, incident_date: Optional[str], 
                                 location: Optional[str]) -> str:
        """Construct the prompt for the IPC-Helper model"""
        prompt = f"""You are an expert Indian legal assistant. Analyze this case and return ONLY the essential information requested below.

Case: {case_description}

INSTRUCTIONS:
1. Identify ALL relevant IPC (Indian Penal Code) sections that apply to this case
2. For each IPC section, provide ONLY:
   - Section number (like 302, 304A, 279, etc.)
   - Brief description of what the section covers
   - Why this section applies to this specific case
3. Determine the case severity (High/Medium/Low)

Return your response in this EXACT JSON format (no other text):

{{
  "applicable_ipc_sections": [
    {{
      "section_number": "302",
      "description": "Whoever commits murder shall be punished with death, or imprisonment for life",
      "why_applicable": "This section applies because the case involves intentional causing of death"
    }},
    {{
      "section_number": "304A", 
      "description": "Whoever causes death by doing any rash or negligent act not amounting to culpable homicide",
      "why_applicable": "This section applies if the death was caused by negligent driving without intention"
    }}
  ],
  "severity": "High"
}}

IMPORTANT: 
- Include ALL possible IPC sections that could apply
- Be concise - no lengthy explanations
- Return ONLY the JSON response, no additional text
- Do not include punishment details, case summaries, or other information"""
        
        return prompt
    
    def _make_ollama_request(self, prompt: str) -> str:
        """Make request to Ollama API with retry logic"""
        url = f"{self.base_url}/api/generate"
        
        payload = {
            "model": self.model_name,
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": 0.3,  # Lower temperature for more consistent legal analysis
                "top_p": 0.9,
                "top_k": 40,
                "num_predict": 2000,  # Limit response length
            }
        }
        
        last_exception = None
        
        for attempt in range(self.max_retries):
            try:
                logger.info(f"Making Ollama request (attempt {attempt + 1}/{self.max_retries}) to {url}")
                logger.info(f"Request timeout set to {self.timeout} seconds")
                
                start_time = timezone.now()
                response = requests.post(
                    url, 
                    json=payload, 
                    timeout=self.timeout,
                    headers={'Content-Type': 'application/json'}
                )
                response.raise_for_status()
                
                elapsed_time = (timezone.now() - start_time).total_seconds()
                logger.info(f"Ollama responded after {elapsed_time:.2f} seconds")
                
                result = response.json()
                response_text = result.get('response', '')
                
                if response_text.strip():
                    logger.info(f"Successfully received response from Ollama ({len(response_text)} characters)")
                    return response_text
                else:
                    logger.warning("Received empty response from Ollama")
                    
            except requests.exceptions.Timeout as e:
                last_exception = e
                logger.warning(f"Ollama request timeout on attempt {attempt + 1}: {str(e)}")
                
            except requests.exceptions.ConnectionError as e:
                last_exception = e
                logger.warning(f"Ollama connection error on attempt {attempt + 1}: {str(e)}")
                
            except requests.exceptions.RequestException as e:
                last_exception = e
                logger.warning(f"Ollama request failed on attempt {attempt + 1}: {str(e)}")
                
            except Exception as e:
                last_exception = e
                logger.error(f"Unexpected error on attempt {attempt + 1}: {str(e)}")
            
            # Wait before retry (except on last attempt)
            if attempt < self.max_retries - 1:
                import time
                time.sleep(2)  # Wait 2 seconds before retry
        
        # All attempts failed
        error_msg = f"Failed to get response from IPC-Helper model after {self.max_retries} attempts"
        if last_exception:
            error_msg += f": {str(last_exception)}"
        
        logger.error(error_msg)
        raise Exception(error_msg)
    
    def _parse_ollama_response(self, response_text: str) -> Dict:
        """Parse the JSON response from Ollama model"""
        try:
            # Clean the response text
            cleaned_response = response_text.strip()
            
            # Try to extract JSON from the response using multiple strategies
            json_patterns = [
                # Pattern 1: Look for complete JSON object
                r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}',
                # Pattern 2: Look for JSON between specific markers
                r'```json\s*(\{.*?\})\s*```',
                # Pattern 3: Look for JSON after specific text
                r'(?:json|JSON).*?(\{.*?\})',
            ]
            
            parsed_json = None
            
            for pattern in json_patterns:
                matches = re.finditer(pattern, cleaned_response, re.DOTALL | re.IGNORECASE)
                for match in matches:
                    try:
                        json_str = match.group(1) if match.groups() else match.group()
                        parsed_json = json.loads(json_str)
                        break
                    except (json.JSONDecodeError, IndexError):
                        continue
                if parsed_json:
                    break
            
            if parsed_json:
                # Validate the structure for new format
                if 'applicable_ipc_sections' in parsed_json and isinstance(parsed_json['applicable_ipc_sections'], list):
                    return parsed_json
                # Also support old format for backward compatibility
                elif 'ipc_sections' in parsed_json and isinstance(parsed_json['ipc_sections'], list):
                    return parsed_json
            
            # If no valid JSON found, try parsing the whole response
            try:
                return json.loads(cleaned_response)
            except json.JSONDecodeError:
                pass
            
            # Fall back to manual parsing
            logger.warning(f"Could not parse JSON from response, falling back to manual parsing")
            return self._manual_parse_response(response_text)
                
        except Exception as e:
            logger.error(f"Failed to parse response: {str(e)}")
            logger.error(f"Raw response: {response_text}")
            return self._manual_parse_response(response_text)
    
    def _manual_parse_response(self, response_text: str) -> Dict:
        """Manually parse response if JSON parsing fails"""
        ipc_sections = []
        
        # Enhanced patterns to extract IPC sections
        patterns = [
            # Pattern 1: "Section 304B", "IPC 304B", "304B"
            r'(?:Section\s+|IPC\s+)?(\d+[A-Z]*)\s*[-:]\s*([^.]*?)(?:\.|$)',
            # Pattern 2: Just section numbers
            r'(?:Section\s+|IPC\s+)?(\d+[A-Z]*)',
        ]
        
        found_sections = set()
        
        for pattern in patterns:
            matches = re.finditer(pattern, response_text, re.IGNORECASE | re.MULTILINE)
            for match in matches:
                section_num = match.group(1)
                description = match.group(2).strip() if len(match.groups()) > 1 else ""
                
                if section_num not in found_sections:
                    found_sections.add(section_num)
                    
                    # Try to find why it's applied by looking at surrounding text
                    why_applied = self._extract_reasoning(response_text, section_num)
                    
                    ipc_sections.append({
                        "section_number": section_num,
                        "description": description or f"IPC Section {section_num} - Details to be verified with legal expert",
                        "why_applicable": why_applied or "Mentioned in analysis - requires legal consultation for specific application"
                    })
        
        # If no sections found, try to extract any legal insights
        if not ipc_sections:
            ipc_sections.append({
                "section_number": "TBD",
                "description": "Analysis requires legal expert review",
                "why_applicable": "Could not automatically identify specific IPC sections from the model response"
            })
        
        return {
            "applicable_ipc_sections": ipc_sections,
            "severity": "Medium",
            "raw_response": response_text,
            "parsing_method": "manual",
            "note": "This analysis was extracted automatically. Please consult a legal expert for accurate interpretation."
        }
    
    def _extract_reasoning(self, text: str, section_num: str) -> str:
        """Extract reasoning for why a section applies"""
        # Look for text around the section number that might explain why it applies
        patterns = [
            rf'(?:{section_num}.*?(?:because|since|as|due to|applies when|relevant when)\s+([^.]*?)\.)',
            rf'(?:(?:because|since|as|due to|applies when|relevant when)\s+([^.]*?)\s+.*?{section_num})',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
            if match:
                return match.group(1).strip()[:200]  # Limit to 200 chars
        
        return ""
    
    def _extract_summary(self, text: str) -> str:
        """Extract a summary from the response text"""
        # Try to find summary-like content
        summary_patterns = [
            r'(?:summary|conclusion|analysis)[:\s]*([^.]*(?:\.[^.]*){1,3})',
            r'^([^.]*(?:\.[^.]*){1,2})',  # First few sentences
        ]
        
        for pattern in summary_patterns:
            match = re.search(pattern, text, re.IGNORECASE | re.MULTILINE)
            if match:
                summary = match.group(1).strip()
                if len(summary) > 50:  # Only use if substantial
                    return summary[:500]  # Limit length
        
        # Fall back to first part of text
        return text[:300] + "..." if len(text) > 300 else text
    
    def _enhance_analysis(self, analysis: Dict) -> Dict:
        """Enhance the analysis with additional processing"""
        enhanced = analysis.copy()
        
        # Standardize the structure based on your model's output format
        if 'ipc_sections' in enhanced:
            sections = enhanced['ipc_sections']
        else:
            sections = []
        
        # Extract section numbers for easier filtering
        section_numbers = []
        for section in sections:
            if isinstance(section, dict) and 'section_number' in section:
                section_numbers.append(section['section_number'])
        
        enhanced['section_numbers_list'] = section_numbers
        
        # Determine case category based on IPC sections
        enhanced['case_category'] = self._determine_case_category(section_numbers)
        
        # Add confidence score (you can implement this based on your model's capabilities)
        enhanced['confidence_score'] = self._calculate_confidence_score(enhanced)
        
        # Add recommended actions
        enhanced['recommended_actions'] = self._get_recommended_actions(enhanced)
        
        # Add timestamp
        enhanced['analysis_timestamp'] = timezone.now().isoformat()
        
        return enhanced
    
    def _determine_case_category(self, section_numbers: List[str]) -> str:
        """Determine case category based on IPC sections"""
        # Map IPC sections to categories
        category_mapping = {
            'criminal': ['302', '304', '307', '323', '324', '325', '326', '376', '377', '420', '467', '468', '471'],
            'theft': ['378', '379', '380', '381', '382'],
            'assault': ['319', '320', '321', '322', '323', '324', '325', '326'],
            'fraud': ['415', '416', '417', '418', '419', '420'],
            'defamation': ['499', '500'],
            'cybercrime': ['66', '67', '72'],  # IT Act sections often mentioned
            'domestic_violence': ['498A', '304B'],
            'corruption': ['7', '13'],  # Prevention of Corruption Act
        }
        
        for category, sections in category_mapping.items():
            if any(sec in section_numbers for sec in sections):
                return category
        
        return 'general_criminal'
    
    def _calculate_confidence_score(self, analysis: Dict) -> float:
        """Calculate confidence score for the analysis"""
        # Simple heuristic - you can make this more sophisticated
        score = 0.5  # Base score
        
        if 'ipc_sections' in analysis and analysis['ipc_sections']:
            score += 0.3  # Bonus for identifying sections
        
        if 'summary' in analysis and len(analysis['summary']) > 100:
            score += 0.2  # Bonus for detailed summary
        
        return min(score, 1.0)
    
    def _get_recommended_actions(self, analysis: Dict) -> List[str]:
        """Generate recommended actions based on analysis"""
        actions = [
            "Consult with a qualified lawyer for detailed legal advice",
            "Gather all relevant documents and evidence",
            "File a police complaint if criminal activity is suspected"
        ]
        
        # Add specific actions based on case category
        category = analysis.get('case_category', '')
        
        if category == 'theft':
            actions.append("Report the theft to local police immediately")
            actions.append("Make a list of stolen items with their approximate values")
        
        elif category == 'assault':
            actions.append("Seek medical attention if injured")
            actions.append("Collect witness statements if available")
        
        elif category == 'fraud':
            actions.append("Report to cyber crime cell if online fraud")
            actions.append("Preserve all communication records")
        
        elif category == 'domestic_violence':
            actions.append("Contact women helpline or protection officer")
            actions.append("Seek medical examination for injuries")
        
        return actions
    
    def _get_fallback_analysis(self, case_description: str) -> Dict:
        """Provide fallback analysis if model is unavailable"""
        return {
            "applicable_ipc_sections": [
                {
                    "section_number": "TBD",
                    "description": "Analysis not available - please consult a lawyer",
                    "why_applicable": "Model unavailable for analysis"
                }
            ],
            "severity": "Unknown",
            "error": "IPC-Helper model unavailable",
            "analysis_timestamp": timezone.now().isoformat(),
            "note": "Please consult a qualified lawyer for proper legal analysis"
        }
    
    def _get_connection_error_fallback(self, case_description: str) -> Dict:
        """Provide fallback analysis for connection errors"""
        return {
            "applicable_ipc_sections": [
                {
                    "section_number": "SERVICE_INTERRUPTED",
                    "description": "Legal analysis service was interrupted. Please try again.",
                    "why_applicable": "Connection to AI legal assistant was lost during processing"
                }
            ],
            "severity": "Unknown",
            "error": "Connection interrupted during analysis",
            "analysis_timestamp": timezone.now().isoformat(),
            "note": "Service was interrupted. Please try submitting your case again. If the issue persists, contact support."
        }
    
    def test_connection(self) -> Tuple[bool, str]:
        """Test connection to Ollama service"""
        try:
            response = requests.get(f"{self.base_url}/api/tags", timeout=10)
            response.raise_for_status()
            
            models = response.json().get('models', [])
            model_names = [model.get('name', '') for model in models]
            
            if self.model_name in model_names:
                return True, f"Successfully connected. Model {self.model_name} is available."
            else:
                return False, f"Model {self.model_name} not found. Available models: {model_names}"
                
        except Exception as e:
            return False, f"Connection failed: {str(e)}"


class LeadMatchingService:
    """Service to match case leads with appropriate lawyers"""
    
    @staticmethod
    def find_matching_lawyers(case_lead, max_matches: int = 10):
        """Find lawyers who match the case requirements"""
        from .models import LawyerProfile
        from django.db.models import Q
        
        # Base query - active, verified lawyers with active subscriptions
        base_query = LawyerProfile.objects.filter(
            profile_complete=True,
            verified=True,
            subscription__status='active'
        ).select_related('subscription', 'user')
        
        # Filter by location (same city or state)
        location_filter = Q(city__iexact=case_lead.city) | Q(state__iexact=case_lead.state)
        
        # Filter by practice areas
        practice_area_filter = Q()
        if case_lead.case_category:
            practice_area_filter = Q(practice_areas__contains=[case_lead.case_category])
        
        # Filter by IPC sections if specific areas are identified
        ipc_filter = Q()
        if case_lead.ipc_sections_identified:
            # Map IPC sections to practice areas
            section_to_area = {
                '302': 'criminal', '304': 'criminal', '307': 'criminal',
                '376': 'criminal', '498A': 'family', '304B': 'family',
                '420': 'criminal', '406': 'criminal'
            }
            
            relevant_areas = set()
            for section in case_lead.ipc_sections_identified:
                if section in section_to_area:
                    relevant_areas.add(section_to_area[section])
            
            if relevant_areas:
                ipc_filter = Q(practice_areas__overlap=list(relevant_areas))
        
        # Apply filters
        matching_lawyers = base_query.filter(
            location_filter & (practice_area_filter | ipc_filter)
        ).distinct()
        
        # Check subscription limits
        eligible_lawyers = []
        for lawyer in matching_lawyers[:max_matches * 2]:  # Get more to filter
            if lawyer.subscription.can_access_leads():
                eligible_lawyers.append(lawyer)
                if len(eligible_lawyers) >= max_matches:
                    break
        
        return eligible_lawyers
    
    @staticmethod
    def notify_matching_lawyers(case_lead, matching_lawyers):
        """Send notifications to matching lawyers"""
        from .tasks import send_lead_notification  # We'll create this
        
        for lawyer in matching_lawyers:
            # Check lawyer's notification preferences
            filters = lawyer.saved_filters.filter(is_active=True)
            
            should_notify = False
            
            if not filters.exists():
                # No specific filters, notify for all relevant cases
                should_notify = True
            else:
                # Check if case matches any saved filters
                for filter_obj in filters:
                    if LeadMatchingService._case_matches_filter(case_lead, filter_obj):
                        should_notify = True
                        break
            
            if should_notify:
                # Queue notification task
                send_lead_notification.delay(case_lead.id, lawyer.id)
    
    @staticmethod
    def _case_matches_filter(case_lead, lawyer_filter):
        """Check if a case matches a lawyer's saved filter"""
        # Check IPC sections
        if (lawyer_filter.ipc_sections and 
            not any(section in case_lead.ipc_sections_identified 
                   for section in lawyer_filter.ipc_sections)):
            return False
        
        # Check case categories
        if (lawyer_filter.case_categories and 
            case_lead.case_category not in lawyer_filter.case_categories):
            return False
        
        # Check cities
        if (lawyer_filter.cities and 
            case_lead.city not in lawyer_filter.cities):
            return False
        
        # Check urgency levels
        if (lawyer_filter.urgency_levels and 
            case_lead.urgency_level not in lawyer_filter.urgency_levels):
            return False
        
        return True


class PDFReportService:
    """Service to generate PDF reports for case analysis"""
    
    @staticmethod
    def generate_case_report(case_lead, analysis_data) -> str:
        """Generate PDF report for the analyzed case"""
        from reportlab.lib.pagesizes import letter, A4
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import inch
        from reportlab.lib import colors
        from django.conf import settings
        import os
        
        # Create filename
        filename = f"case_analysis_{case_lead.lead_id}.pdf"
        filepath = os.path.join(settings.MEDIA_ROOT, 'reports', filename)
        
        # Ensure directory exists
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        
        # Create PDF
        doc = SimpleDocTemplate(filepath, pagesize=A4)
        styles = getSampleStyleSheet()
        story = []
        
        # Title
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=18,
            spaceAfter=30,
            alignment=1  # Center alignment
        )
        
        story.append(Paragraph("IPC Justice Aid - Legal Case Analysis Report", title_style))
        story.append(Spacer(1, 12))
        
        # Case details
        story.append(Paragraph("Case Details", styles['Heading2']))
        
        case_data = [
            ['Case ID:', str(case_lead.lead_id)],
            ['Analysis Date:', case_lead.created_at.strftime('%B %d, %Y at %I:%M %p')],
            ['Location:', f"{case_lead.city}, {case_lead.state}"],
            ['Urgency Level:', case_lead.urgency_level.title()],
        ]
        
        if case_lead.incident_date:
            case_data.append(['Incident Date:', case_lead.incident_date.strftime('%B %d, %Y')])
        
        case_table = Table(case_data, colWidths=[2*inch, 4*inch])
        case_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ]))
        
        story.append(case_table)
        story.append(Spacer(1, 12))
        
        # Case description
        story.append(Paragraph("Case Description", styles['Heading2']))
        story.append(Paragraph(case_lead.case_description, styles['Normal']))
        story.append(Spacer(1, 12))
        
        # IPC Analysis
        story.append(Paragraph("IPC Sections Analysis", styles['Heading2']))
        
        if analysis_data.get('ipc_sections'):
            for section in analysis_data['ipc_sections']:
                story.append(Paragraph(f"<b>Section {section.get('section_number', 'N/A')}</b>", styles['Heading3']))
                story.append(Paragraph(section.get('description', 'No description available'), styles['Normal']))
                story.append(Paragraph(f"<b>Why Applied:</b> {section.get('why_applied', 'No explanation available')}", styles['Normal']))
                story.append(Spacer(1, 6))
        
        # Summary
        if analysis_data.get('summary'):
            story.append(Paragraph("Summary", styles['Heading2']))
            story.append(Paragraph(analysis_data['summary'], styles['Normal']))
            story.append(Spacer(1, 12))
        
        # Recommended actions
        if analysis_data.get('recommended_actions'):
            story.append(Paragraph("Recommended Actions", styles['Heading2']))
            for i, action in enumerate(analysis_data['recommended_actions'], 1):
                story.append(Paragraph(f"{i}. {action}", styles['Normal']))
            story.append(Spacer(1, 12))
        
        # Disclaimer
        disclaimer_style = ParagraphStyle(
            'Disclaimer',
            parent=styles['Normal'],
            fontSize=8,
            textColor=colors.grey,
            borderWidth=1,
            borderColor=colors.grey,
            borderPadding=6
        )
        
        disclaimer_text = """
        <b>DISCLAIMER:</b> This analysis is generated by an AI system and is for informational purposes only. 
        It should not be considered as legal advice. Please consult with a qualified lawyer for proper legal guidance 
        specific to your case. The Indian Penal Code sections mentioned are based on AI interpretation and may not 
        be comprehensive or fully accurate for your specific situation.
        """
        
        story.append(Paragraph(disclaimer_text, disclaimer_style))
        
        # Build PDF
        doc.build(story)
        
        return filename
