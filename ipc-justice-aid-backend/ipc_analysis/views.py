from rest_framework import status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.generics import ListCreateAPIView, RetrieveAPIView
from django.db import transaction
from django.utils import timezone

from .models import LegalCase, LegalAnalysis, AnalysisHistory, IPCSection
from .serializers import (
    LegalCaseSerializer, LegalAnalysisSerializer, AnalysisHistorySerializer,
    CaseAnalysisRequestSerializer, CaseAnalysisResponseSerializer, IPCSectionSerializer
)
from .services import OllamaService
from .adaptive_service import adaptive_analysis_service
from .ocr_service import OCRService
from .document_summarizer_service import DocumentSummarizerService


class AnalyzeCaseView(APIView):
    """
    Main endpoint for analyzing legal cases using adaptive AI service (Ollama/HuggingFace)
    """
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        serializer = CaseAnalysisRequestSerializer(data=request.data)
        
        if not serializer.is_valid():
            return Response(
                {'error': 'Invalid input', 'details': serializer.errors},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        case_description = serializer.validated_data['case_description']
        
        try:
            with transaction.atomic():
                # Create the legal case
                legal_case = LegalCase.objects.create(
                    user=request.user,
                    case_description=case_description
                )
                
                # Call adaptive analysis service (Ollama for dev, HuggingFace for prod)
                result = adaptive_analysis_service.analyze_case(case_description)
                
                if not result['success']:
                    return Response(
                        {
                            'error': 'Analysis failed',
                            'details': result['error'],
                            'response_time_ms': result['response_time_ms']
                        },
                        status=status.HTTP_503_SERVICE_UNAVAILABLE
                    )
                
                # Create the analysis record
                analysis = LegalAnalysis.objects.create(
                    legal_case=legal_case,
                    analysis_json=result['analysis']
                )
                
                # Create history record
                AnalysisHistory.objects.create(
                    user=request.user,
                    case_description=case_description,
                    ollama_response=result['analysis'],
                    response_time_ms=result['response_time_ms']
                )
                
                # Link relevant IPC sections
                self._link_ipc_sections(analysis, result['analysis'])
                
                # Prepare response
                response_data = {
                    'case_id': legal_case.id,
                    'analysis_id': analysis.id,
                    'case_description': case_description,
                    'sections_applied': analysis.get_sections_applied(),
                    'explanation': analysis.get_explanation(),
                    'analyzed_at': analysis.analyzed_at,
                    'response_time_ms': result['response_time_ms']
                }
                
                response_serializer = CaseAnalysisResponseSerializer(response_data)
                return Response(response_serializer.data, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return Response(
                {'error': 'Internal server error', 'details': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def _link_ipc_sections(self, analysis, analysis_json):
        """Link analysis to relevant IPC sections"""
        if 'sections_applied' in analysis_json:
            for section_data in analysis_json['sections_applied']:
                section_number = section_data.get('section_number')
                if section_number:
                    # Try to find or create IPC section
                    ipc_section, created = IPCSection.objects.get_or_create(
                        section_number=section_number,
                        defaults={
                            'title': section_data.get('description', ''),
                            'description': section_data.get('reason', ''),
                        }
                    )
                    analysis.primary_sections.add(ipc_section)


class LegalCaseListView(ListCreateAPIView):
    """
    List and create legal cases
    """
    serializer_class = LegalCaseSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return LegalCase.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class LegalAnalysisDetailView(RetrieveAPIView):
    """
    Retrieve detailed analysis for a specific case
    """
    serializer_class = LegalAnalysisSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return LegalAnalysis.objects.filter(legal_case__user=self.request.user)


class AnalysisHistoryView(ListCreateAPIView):
    """
    View analysis history for the authenticated user
    """
    serializer_class = AnalysisHistorySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return AnalysisHistory.objects.filter(user=self.request.user)


class IPCSectionListView(ListCreateAPIView):
    """
    List IPC sections (public endpoint for reference)
    """
    queryset = IPCSection.objects.all()
    serializer_class = IPCSectionSerializer
    permission_classes = [permissions.AllowAny]


@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def health_check(request):
    """Health check endpoint"""
    return Response({
        'status': 'ok',
        'message': 'IPC Justice Aid API is running',
        'timestamp': timezone.now()
    })


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def ollama_health_check(request):
    """Check AI analysis service health (Ollama/HuggingFace)"""
    health_status = adaptive_analysis_service.health_check()
    service_info = adaptive_analysis_service.get_service_info()
    
    return Response({
        'analysis_service': health_status,
        'service_info': service_info,
        'timestamp': timezone.now()
    })


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def user_stats(request):
    """Get user statistics"""
    user = request.user
    
    total_cases = LegalCase.objects.filter(user=user).count()
    total_analyses = AnalysisHistory.objects.filter(user=user).count()
    
    recent_analysis = AnalysisHistory.objects.filter(user=user).first()
    
    stats = {
        'total_cases_analyzed': total_cases,
        'total_analysis_requests': total_analyses,
        'last_analysis_date': recent_analysis.request_timestamp if recent_analysis else None,
        'user_since': user.date_joined,
    }
    
    return Response(stats)


class ExtractTextFromImageView(APIView):
    """
    Endpoint for extracting text from uploaded images using OCR
    """
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        """Extract text from uploaded image"""
        
        # Check if image file is provided
        if 'image' not in request.FILES:
            return Response(
                {'error': 'No image file provided'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        image_file = request.FILES['image']
        ocr_service = OCRService()
        
        # Validate image file
        validation_result = ocr_service.validate_image_file(image_file)
        if not validation_result['valid']:
            return Response(
                {'error': validation_result['error']},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Extract text from image
            extraction_result = ocr_service.extract_text_from_image(image_file)
            
            if not extraction_result['success']:
                return Response(
                    {
                        'error': 'OCR extraction failed',
                        'details': extraction_result['error']
                    },
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
            
            # Return successful result
            return Response({
                'success': True,
                'extracted_text': extraction_result['text'],
                'confidence': extraction_result['confidence'],
                'metadata': {
                    'word_count': extraction_result['word_count'],
                    'character_count': extraction_result['character_count'],
                    'image_size': extraction_result['image_size'],
                    'file_info': {
                        'name': image_file.name,
                        'size_mb': validation_result['size_mb'],
                        'format': validation_result['format']
                    }
                }
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {
                    'error': 'Internal server error during OCR processing',
                    'details': str(e)
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class DocumentSummarizerView(APIView):
    """
    Endpoint for summarizing documents using AI
    """
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        """Summarize uploaded document"""
        
        # Check if document file is provided
        if 'document' not in request.FILES:
            return Response(
                {'error': 'No document file provided'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        document_file = request.FILES['document']
        
        # Determine file type from content type
        file_type = None
        if document_file.content_type == 'application/pdf':
            file_type = 'pdf'
        elif document_file.content_type.startswith('image/'):
            file_type = 'image'
        else:
            return Response(
                {'error': f'Unsupported file type: {document_file.content_type}'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        summarizer_service = DocumentSummarizerService()
        
        # Validate document file
        validation_result = summarizer_service.validate_document_file(document_file, file_type)
        if not validation_result['valid']:
            return Response(
                {'error': validation_result['error']},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Summarize document
            summary_result = summarizer_service.summarize_document(document_file, file_type)
            
            if not summary_result['success']:
                return Response(
                    {
                        'error': 'Document summarization failed',
                        'details': summary_result['error']
                    },
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
            
            # Return successful result
            return Response({
                'success': True,
                'summary': summary_result['summary'],
                'metadata': {
                    'word_count': summary_result['word_count'],
                    'character_count': summary_result['character_count'],
                    'file_info': summary_result['file_info']
                },
                'extracted_text': summary_result['extracted_text']
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {
                    'error': 'Internal server error during document summarization',
                    'details': str(e)
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
