from django.db import models
from django.contrib.auth import get_user_model
from django.conf import settings
import json

User = get_user_model()


class LegalCase(models.Model):
    """Model to store legal case descriptions and analysis"""
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='legal_cases')
    case_description = models.TextField(help_text="Description of the legal case")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Case by {self.user.email} - {self.case_description[:50]}..."


class IPCSection(models.Model):
    """Model to store IPC section details"""
    section_number = models.CharField(max_length=10, unique=True)
    title = models.CharField(max_length=255)
    description = models.TextField()
    penalty = models.TextField(blank=True, null=True)
    
    class Meta:
        ordering = ['section_number']
    
    def __str__(self):
        return f"Section {self.section_number}: {self.title}"


class LegalAnalysis(models.Model):
    """Model to store the AI analysis results for a case"""
    legal_case = models.OneToOneField(LegalCase, on_delete=models.CASCADE, related_name='analysis')
    analysis_json = models.JSONField(help_text="Raw JSON response from Ollama model")
    analyzed_at = models.DateTimeField(auto_now_add=True)
    
    # Extracted fields for easier querying
    primary_sections = models.ManyToManyField(IPCSection, related_name='primary_analyses')
    
    def get_sections_applied(self):
        """Extract sections from the JSON analysis"""
        if self.analysis_json and 'sections_applied' in self.analysis_json:
            return self.analysis_json['sections_applied']
        return []
    
    def get_explanation(self):
        """Extract explanation from the JSON analysis"""
        if self.analysis_json and 'explanation' in self.analysis_json:
            return self.analysis_json['explanation']
        return ""
    
    class Meta:
        ordering = ['-analyzed_at']
    
    def __str__(self):
        return f"Analysis for: {self.legal_case.case_description[:50]}..."


class AnalysisHistory(models.Model):
    """Model to track analysis requests and responses"""
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='analysis_history')
    case_description = models.TextField()
    ollama_response = models.JSONField()
    request_timestamp = models.DateTimeField(auto_now_add=True)
    response_time_ms = models.IntegerField(help_text="Response time in milliseconds")
    
    class Meta:
        ordering = ['-request_timestamp']
        verbose_name_plural = "Analysis Histories"
    
    def __str__(self):
        return f"Analysis by {self.user.email} at {self.request_timestamp}"
