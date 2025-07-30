from rest_framework import serializers
from .models import LegalCase, IPCSection, LegalAnalysis, AnalysisHistory


class IPCSectionSerializer(serializers.ModelSerializer):
    class Meta:
        model = IPCSection
        fields = ['id', 'section_number', 'title', 'description', 'penalty']


class LegalCaseSerializer(serializers.ModelSerializer):
    user = serializers.StringRelatedField(read_only=True)
    
    class Meta:
        model = LegalCase
        fields = ['id', 'user', 'case_description', 'created_at', 'updated_at']
        read_only_fields = ['user', 'created_at', 'updated_at']


class LegalAnalysisSerializer(serializers.ModelSerializer):
    legal_case = LegalCaseSerializer(read_only=True)
    primary_sections = IPCSectionSerializer(many=True, read_only=True)
    sections_applied = serializers.SerializerMethodField()
    explanation = serializers.SerializerMethodField()
    
    class Meta:
        model = LegalAnalysis
        fields = [
            'id', 'legal_case', 'analysis_json', 'analyzed_at', 
            'primary_sections', 'sections_applied', 'explanation'
        ]
        read_only_fields = ['analyzed_at']
    
    def get_sections_applied(self, obj):
        return obj.get_sections_applied()
    
    def get_explanation(self, obj):
        return obj.get_explanation()


class AnalysisHistorySerializer(serializers.ModelSerializer):
    user = serializers.StringRelatedField(read_only=True)
    
    class Meta:
        model = AnalysisHistory
        fields = [
            'id', 'user', 'case_description', 'ollama_response', 
            'request_timestamp', 'response_time_ms'
        ]
        read_only_fields = ['user', 'request_timestamp']


class CaseAnalysisRequestSerializer(serializers.Serializer):
    """Serializer for incoming case analysis requests"""
    case_description = serializers.CharField(
        max_length=5000, 
        help_text="Description of the legal case to analyze"
    )
    
    def validate_case_description(self, value):
        if len(value.strip()) < 10:
            raise serializers.ValidationError(
                "Case description must be at least 10 characters long."
            )
        return value.strip()


class CaseAnalysisResponseSerializer(serializers.Serializer):
    """Serializer for outgoing case analysis responses"""
    case_id = serializers.IntegerField()
    analysis_id = serializers.IntegerField()
    case_description = serializers.CharField()
    sections_applied = serializers.ListField()
    explanation = serializers.CharField()
    analyzed_at = serializers.DateTimeField()
    response_time_ms = serializers.IntegerField()
