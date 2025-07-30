from django.contrib import admin
from .models import LegalCase, IPCSection, LegalAnalysis, AnalysisHistory


@admin.register(IPCSection)
class IPCSectionAdmin(admin.ModelAdmin):
    list_display = ['section_number', 'title', 'description']
    search_fields = ['section_number', 'title', 'description']
    list_filter = ['section_number']
    ordering = ['section_number']


@admin.register(LegalCase)
class LegalCaseAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'case_description_preview', 'created_at']
    list_filter = ['created_at', 'updated_at']
    search_fields = ['user__username', 'case_description']
    readonly_fields = ['created_at', 'updated_at']
    date_hierarchy = 'created_at'
    
    def case_description_preview(self, obj):
        return f"{obj.case_description[:100]}..." if len(obj.case_description) > 100 else obj.case_description
    case_description_preview.short_description = 'Case Description'


@admin.register(LegalAnalysis)
class LegalAnalysisAdmin(admin.ModelAdmin):
    list_display = ['id', 'legal_case_preview', 'analyzed_at', 'sections_count']
    list_filter = ['analyzed_at']
    search_fields = ['legal_case__case_description', 'legal_case__user__username']
    readonly_fields = ['analyzed_at']
    date_hierarchy = 'analyzed_at'
    filter_horizontal = ['primary_sections']
    
    def legal_case_preview(self, obj):
        return f"{obj.legal_case.case_description[:50]}..."
    legal_case_preview.short_description = 'Legal Case'
    
    def sections_count(self, obj):
        return obj.primary_sections.count()
    sections_count.short_description = 'IPC Sections Count'


@admin.register(AnalysisHistory)
class AnalysisHistoryAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'case_preview', 'request_timestamp', 'response_time_ms']
    list_filter = ['request_timestamp', 'response_time_ms']
    search_fields = ['user__username', 'case_description']
    readonly_fields = ['request_timestamp']
    date_hierarchy = 'request_timestamp'
    
    def case_preview(self, obj):
        return f"{obj.case_description[:50]}..."
    case_preview.short_description = 'Case Description'
