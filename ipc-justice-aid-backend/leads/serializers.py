from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import (
    LawyerProfile, Subscription, CaseLead, LeadAssignment, 
    LawyerLeadFilter, LeadAnalytics, CitizenFeedback
)

User = get_user_model()


class LawyerProfileSerializer(serializers.ModelSerializer):
    user_details = serializers.SerializerMethodField()
    practice_areas_display = serializers.SerializerMethodField()
    
    class Meta:
        model = LawyerProfile
        fields = [
            'id', 'user_details', 'bar_council_id', 'practice_areas', 
            'practice_areas_display', 'experience_level', 'years_of_experience',
            'city', 'state', 'court_locations', 'firm_name', 'languages_spoken',
            'consultation_fee', 'email_notifications', 'sms_notifications',
            'preferred_contact_time', 'profile_complete', 'verified', 'created_at'
        ]
        read_only_fields = ['verified', 'profile_complete']
    
    def get_user_details(self, obj):
        return {
            'username': obj.user.username,
            'first_name': obj.user.first_name,
            'last_name': obj.user.last_name,
            'email': obj.user.email,
        }
    
    def get_practice_areas_display(self, obj):
        return obj.get_practice_areas_display()


class SubscriptionSerializer(serializers.ModelSerializer):
    lawyer_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Subscription
        fields = [
            'id', 'lawyer_name', 'tier', 'status', 'monthly_lead_limit',
            'current_month_leads_consumed', 'monthly_price', 'start_date',
            'end_date', 'last_payment_date', 'next_billing_date'
        ]
        read_only_fields = ['current_month_leads_consumed', 'last_payment_date']
    
    def get_lawyer_name(self, obj):
        return obj.lawyer.user.get_full_name() or obj.lawyer.user.username


class CaseLeadSerializer(serializers.ModelSerializer):
    ipc_sections_display = serializers.SerializerMethodField()
    time_since_created = serializers.SerializerMethodField()
    matching_lawyer_count = serializers.SerializerMethodField()
    
    class Meta:
        model = CaseLead
        fields = [
            'lead_id', 'case_description', 'incident_date', 'incident_location',
            'city', 'state', 'ai_analysis', 'ipc_sections_identified',
            'ipc_sections_display', 'case_category', 'urgency_level',
            'contact_method', 'status', 'created_at', 'expires_at',
            'time_since_created', 'matching_lawyer_count'
        ]
        read_only_fields = ['lead_id', 'ai_analysis', 'ipc_sections_identified', 'case_category']
    
    def get_ipc_sections_display(self, obj):
        """Return formatted IPC sections from AI analysis"""
        if obj.ai_analysis and 'ipc_sections' in obj.ai_analysis:
            sections = obj.ai_analysis['ipc_sections']
            return [f"Section {s.get('section_number', 'N/A')}" for s in sections]
        return []
    
    def get_time_since_created(self, obj):
        from django.utils import timezone
        delta = timezone.now() - obj.created_at
        
        if delta.days > 0:
            return f"{delta.days} days ago"
        elif delta.seconds > 3600:
            hours = delta.seconds // 3600
            return f"{hours} hours ago"
        else:
            minutes = delta.seconds // 60
            return f"{minutes} minutes ago"
    
    def get_matching_lawyer_count(self, obj):
        return obj.get_matching_lawyers().count()


class CaseLeadDetailSerializer(CaseLeadSerializer):
    """Detailed serializer for single lead view"""
    assigned_lawyers_details = serializers.SerializerMethodField()
    analytics = serializers.SerializerMethodField()
    
    class Meta(CaseLeadSerializer.Meta):
        fields = CaseLeadSerializer.Meta.fields + ['assigned_lawyers_details', 'analytics']
    
    def get_assigned_lawyers_details(self, obj):
        assignments = LeadAssignment.objects.filter(lead=obj).select_related('lawyer__user')
        return [{
            'lawyer_name': assignment.lawyer.user.get_full_name() or assignment.lawyer.user.username,
            'action': assignment.action,
            'last_action_at': assignment.last_action_at,
            'lawyer_message': assignment.lawyer_message[:100] + '...' if len(assignment.lawyer_message) > 100 else assignment.lawyer_message
        } for assignment in assignments]
    
    def get_analytics(self, obj):
        try:
            analytics = obj.analytics
            return {
                'total_views': analytics.total_views,
                'unique_lawyer_views': analytics.unique_lawyer_views,
                'interested_lawyers_count': analytics.interested_lawyers_count,
                'contacted_lawyers_count': analytics.contacted_lawyers_count,
            }
        except LeadAnalytics.DoesNotExist:
            return None


class LeadAssignmentSerializer(serializers.ModelSerializer):
    lawyer_details = serializers.SerializerMethodField()
    lead_summary = serializers.SerializerMethodField()
    
    class Meta:
        model = LeadAssignment
        fields = [
            'id', 'lawyer_details', 'lead_summary', 'action',
            'lawyer_message', 'client_response', 'assigned_at', 'last_action_at'
        ]
    
    def get_lawyer_details(self, obj):
        return {
            'name': obj.lawyer.user.get_full_name() or obj.lawyer.user.username,
            'firm_name': obj.lawyer.firm_name,
            'experience_level': obj.lawyer.get_experience_level_display(),
            'consultation_fee': obj.lawyer.consultation_fee,
        }
    
    def get_lead_summary(self, obj):
        return {
            'lead_id': str(obj.lead.lead_id),
            'case_category': obj.lead.case_category,
            'location': f"{obj.lead.city}, {obj.lead.state}",
            'urgency_level': obj.lead.urgency_level,
        }


class LawyerLeadFilterSerializer(serializers.ModelSerializer):
    class Meta:
        model = LawyerLeadFilter
        fields = [
            'id', 'filter_name', 'ipc_sections', 'case_categories',
            'cities', 'urgency_levels', 'email_notifications',
            'sms_notifications', 'real_time_notifications', 'is_active', 'created_at'
        ]


class CitizenFeedbackSerializer(serializers.ModelSerializer):
    class Meta:
        model = CitizenFeedback
        fields = [
            'id', 'ai_analysis_rating', 'lawyer_response_rating',
            'overall_experience_rating', 'comments', 'would_recommend',
            'improvement_suggestions', 'created_at'
        ]


class CaseAnalysisRequestSerializer(serializers.Serializer):
    """Serializer for citizen case analysis requests"""
    # Required field - only case description needed for analysis
    case_description = serializers.CharField(max_length=5000, help_text="Description of your legal case/incident")
    
    # Optional fields - only needed if user wants to create a lead for lawyer connection
    incident_date = serializers.DateField(required=False, allow_null=True, help_text="Date when the incident occurred")
    incident_location = serializers.CharField(max_length=200, required=False, help_text="Specific location where incident occurred")
    city = serializers.CharField(max_length=100, required=False, help_text="City - required for lawyer matching")
    state = serializers.CharField(max_length=100, required=False, help_text="State - required for lawyer matching")
    contact_method = serializers.ChoiceField(
        choices=[
            ('email', 'Temporary Email'),
            ('telegram', 'Telegram ID'),
            ('phone', 'Temporary Phone'),
        ],
        required=False,
        help_text="How lawyers can contact you"
    )
    contact_value = serializers.CharField(max_length=200, required=False, help_text="Your contact information")
    urgency_level = serializers.ChoiceField(
        choices=[('low', 'Low'), ('medium', 'Medium'), ('high', 'High'), ('critical', 'Critical')],
        default='medium',
        required=False,
        help_text="How urgent is your case"
    )
    
    # Control flags
    create_lead = serializers.BooleanField(default=False, help_text="Set to true if you want lawyer connections")
    generate_pdf = serializers.BooleanField(default=False, help_text="Generate PDF report")
    
    def validate(self, attrs):
        """Validate that required fields for lead creation are provided if create_lead is True"""
        if attrs.get('create_lead', False):
            required_for_lead = ['incident_location', 'city', 'state', 'contact_method', 'contact_value']
            for field in required_for_lead:
                if not attrs.get(field):
                    raise serializers.ValidationError(
                        f"'{field}' is required when create_lead is True"
                    )
        return attrs


class CaseAnalysisResponseSerializer(serializers.Serializer):
    """Serializer for case analysis responses"""
    # Core analysis results
    ipc_sections = serializers.ListField(help_text="List of applicable IPC sections with details")
    summary = serializers.CharField(help_text="AI-generated summary of the case analysis")
    case_category = serializers.CharField(help_text="Category of the legal case")
    confidence_score = serializers.FloatField(help_text="AI confidence in the analysis (0.0 to 1.0)")
    recommended_actions = serializers.ListField(help_text="Recommended next steps")
    analysis_timestamp = serializers.CharField(help_text="When the analysis was performed")
    
    # Optional lead information (only if lead was created)
    lead_id = serializers.UUIDField(required=False, allow_null=True, help_text="Lead ID if lawyer connection was requested")
    lawyer_connect_available = serializers.BooleanField(default=False, help_text="Whether lawyer connection is available")
    pdf_report_url = serializers.URLField(required=False, allow_null=True, help_text="URL to download PDF report")
    estimated_consultation_fee_range = serializers.CharField(required=False, help_text="Expected consultation fee range")
    
    # System information
    note = serializers.CharField(required=False, help_text="Additional notes about the analysis")
    disclaimer = serializers.CharField(
        default="This is an AI-generated analysis for informational purposes only. Please consult a qualified lawyer for legal advice.",
        help_text="Legal disclaimer"
    )


class LawyerDashboardStatsSerializer(serializers.Serializer):
    """Serializer for lawyer dashboard statistics"""
    total_leads_viewed = serializers.IntegerField()
    leads_contacted = serializers.IntegerField()
    leads_accepted = serializers.IntegerField()
    leads_rejected = serializers.IntegerField()
    current_month_consumption = serializers.IntegerField()
    monthly_limit = serializers.IntegerField()
    subscription_status = serializers.CharField()
    new_leads_today = serializers.IntegerField()
    pending_responses = serializers.IntegerField()
