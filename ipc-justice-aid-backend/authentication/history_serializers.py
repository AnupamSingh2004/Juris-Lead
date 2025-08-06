from rest_framework import serializers
from .history_models import UserActivityHistory, UserAnalyticsData


class UserActivityHistorySerializer(serializers.ModelSerializer):
    time_ago = serializers.ReadOnlyField()
    icon_name = serializers.ReadOnlyField()
    activity_type_display = serializers.CharField(source='get_activity_type_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    
    class Meta:
        model = UserActivityHistory
        fields = [
            'id', 'activity_type', 'activity_type_display', 'title', 'description',
            'status', 'status_display', 'result_data', 'file_name', 'file_size', 
            'file_type', 'created_at', 'duration_seconds', 'time_ago', 'icon_name',
            'page_url', 'additional_data'
        ]
        read_only_fields = ['id', 'created_at', 'time_ago', 'icon_name']


class UserAnalyticsDataSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserAnalyticsData
        fields = [
            'total_analyses', 'total_documents_processed', 'total_cases_created',
            'total_lawyer_searches', 'total_legal_research', 'total_time_spent_minutes',
            'last_activity_date', 'total_files_uploaded', 'total_file_size_mb',
            'monthly_analyses', 'monthly_documents', 'monthly_cases', 'updated_at'
        ]
        read_only_fields = ['updated_at']


class CreateActivitySerializer(serializers.ModelSerializer):
    """Serializer for creating new activity records"""
    
    class Meta:
        model = UserActivityHistory
        fields = [
            'activity_type', 'title', 'description', 'status', 'result_data',
            'file_name', 'file_size', 'file_type', 'duration_seconds',
            'page_url', 'referrer_url', 'additional_data'
        ]
    
    def create(self, validated_data):
        # Add user and request metadata
        request = self.context.get('request')
        if request:
            validated_data['user'] = request.user
            validated_data['ip_address'] = self.get_client_ip(request)
            validated_data['user_agent'] = request.META.get('HTTP_USER_AGENT', '')
            validated_data['session_id'] = request.session.session_key or ''
        
        return super().create(validated_data)
    
    def get_client_ip(self, request):
        """Get client IP address from request"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            return x_forwarded_for.split(',')[0]
        return request.META.get('REMOTE_ADDR', '')
