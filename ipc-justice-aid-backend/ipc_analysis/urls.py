from django.urls import path
from .views import (
    AnalyzeCaseView, LegalCaseListView, LegalAnalysisDetailView,
    AnalysisHistoryView, IPCSectionListView, health_check,
    ollama_health_check, user_stats, ExtractTextFromImageView,
    DocumentSummarizerView
)

app_name = 'ipc_analysis'

urlpatterns = [
    # Main analysis endpoint
    path('analyze/', AnalyzeCaseView.as_view(), name='analyze_case'),
    
    # OCR endpoint
    path('extract-text/', ExtractTextFromImageView.as_view(), name='extract_text_from_image'),
    
    # Document summarizer endpoint
    path('summarize-document/', DocumentSummarizerView.as_view(), name='summarize_document'),
    
    # Case management
    path('cases/', LegalCaseListView.as_view(), name='legal_cases'),
    path('analysis/<int:pk>/', LegalAnalysisDetailView.as_view(), name='analysis_detail'),
    
    # History and stats
    path('history/', AnalysisHistoryView.as_view(), name='analysis_history'),
    path('stats/', user_stats, name='user_stats'),
    
    # IPC sections reference
    path('ipc-sections/', IPCSectionListView.as_view(), name='ipc_sections'),
    
    # Health checks
    path('health/', health_check, name='health_check'),
    path('ollama-health/', ollama_health_check, name='ollama_health'),
]
