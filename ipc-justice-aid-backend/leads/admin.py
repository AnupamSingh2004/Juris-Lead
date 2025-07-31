from django.contrib import admin
from .models import (
    LawyerProfile, Subscription, CaseLead, LeadAssignment,
    LawyerLeadFilter, LeadAnalytics, CitizenFeedback
)


@admin.register(LawyerProfile)
class LawyerProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'bar_council_id', 'city', 'state', 'experience_level', 'verified', 'profile_complete']
    list_filter = ['verified', 'profile_complete', 'experience_level', 'state', 'created_at']
    search_fields = ['user__username', 'user__email', 'bar_council_id', 'city', 'firm_name']
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('User Information', {
            'fields': ('user',)
        }),
        ('Professional Details', {
            'fields': ('bar_council_id', 'practice_areas', 'experience_level', 'years_of_experience', 'firm_name')
        }),
        ('Location', {
            'fields': ('city', 'state', 'court_locations')
        }),
        ('Contact & Preferences', {
            'fields': ('languages_spoken', 'consultation_fee', 'email_notifications', 'sms_notifications', 'preferred_contact_time')
        }),
        ('Verification', {
            'fields': ('profile_complete', 'verified', 'verification_documents')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        })
    )


@admin.register(Subscription)
class SubscriptionAdmin(admin.ModelAdmin):
    list_display = ['lawyer', 'tier', 'status', 'monthly_lead_limit', 'current_month_leads_consumed', 'monthly_price']
    list_filter = ['tier', 'status', 'created_at']
    search_fields = ['lawyer__user__username', 'lawyer__user__email']
    readonly_fields = ['created_at', 'updated_at']
    
    actions = ['reset_monthly_consumption']
    
    def reset_monthly_consumption(self, request, queryset):
        for subscription in queryset:
            subscription.reset_monthly_consumption()
        self.message_user(request, f"Reset monthly consumption for {queryset.count()} subscriptions.")
    reset_monthly_consumption.short_description = "Reset monthly lead consumption"


@admin.register(CaseLead)
class CaseLeadAdmin(admin.ModelAdmin):
    list_display = ['lead_id', 'case_category', 'city', 'state', 'urgency_level', 'status', 'created_at']
    list_filter = ['status', 'case_category', 'urgency_level', 'state', 'created_at']
    search_fields = ['lead_id', 'case_description', 'city', 'case_category']
    readonly_fields = ['lead_id', 'created_at', 'updated_at', 'ai_analysis']
    
    fieldsets = (
        ('Case Information', {
            'fields': ('lead_id', 'case_description', 'incident_date', 'incident_location')
        }),
        ('Location', {
            'fields': ('city', 'state')
        }),
        ('AI Analysis', {
            'fields': ('ai_analysis', 'ipc_sections_identified', 'case_category'),
            'classes': ('collapse',)
        }),
        ('Contact & Status', {
            'fields': ('contact_method', 'contact_value', 'urgency_level', 'status', 'expires_at')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        })
    )


@admin.register(LeadAssignment)
class LeadAssignmentAdmin(admin.ModelAdmin):
    list_display = ['lead', 'lawyer', 'action', 'assigned_at', 'last_action_at']
    list_filter = ['action', 'assigned_at']
    search_fields = ['lead__lead_id', 'lawyer__user__username']
    readonly_fields = ['assigned_at', 'last_action_at']


@admin.register(LawyerLeadFilter)
class LawyerLeadFilterAdmin(admin.ModelAdmin):
    list_display = ['lawyer', 'filter_name', 'is_active', 'email_notifications', 'created_at']
    list_filter = ['is_active', 'email_notifications', 'created_at']
    search_fields = ['lawyer__user__username', 'filter_name']


@admin.register(LeadAnalytics)
class LeadAnalyticsAdmin(admin.ModelAdmin):
    list_display = ['lead', 'total_views', 'unique_lawyer_views', 'interested_lawyers_count', 'contacted_lawyers_count']
    readonly_fields = ['created_at', 'updated_at']
    search_fields = ['lead__lead_id']


@admin.register(CitizenFeedback)
class CitizenFeedbackAdmin(admin.ModelAdmin):
    list_display = ['lead', 'ai_analysis_rating', 'overall_experience_rating', 'would_recommend', 'created_at']
    list_filter = ['ai_analysis_rating', 'overall_experience_rating', 'would_recommend', 'created_at']
    readonly_fields = ['created_at']
    search_fields = ['lead__lead_id']
