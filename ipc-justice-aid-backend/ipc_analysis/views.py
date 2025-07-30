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


class AnalyzeCaseView(APIView):
    """
    Main endpoint for analyzing legal cases using Ollama model
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
                
                # Call Ollama service
                ollama_service = OllamaService()
                result = ollama_service.analyze_case(case_description)
                
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
    """Check Ollama service health"""
    ollama_service = OllamaService()
    health_status = ollama_service.health_check()
    
    return Response({
        'ollama_service': health_status,
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
