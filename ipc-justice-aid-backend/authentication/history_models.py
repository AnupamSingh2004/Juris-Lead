from django.db import models
from django.utils import timezone
from .models import User
import uuid


class UserActivityHistory(models.Model):
    """Model to track user activities across the platform"""
    
    ACTIVITY_TYPES = [
        # Analysis Activities
        ('document_analysis', 'Document Analysis'),
        ('case_analysis', 'Case Analysis'),
        ('ipc_analysis', 'IPC Section Analysis'),
        
        # Case Activities
        ('case_creation', 'Case Creation'),
        ('case_update', 'Case Update'),
        ('case_search', 'Case Search'),
        
        # Legal Activities
        ('lawyer_search', 'Lawyer Search'),
        ('lawyer_contact', 'Lawyer Contact'),
        ('consultation_request', 'Consultation Request'),
        
        # Document Activities
        ('document_upload', 'Document Upload'),
        ('document_summarization', 'Document Summarization'),
        ('document_download', 'Document Download'),
        
        # Learning Activities
        ('legal_case_study', 'Legal Case Study'),
        ('ipc_section_study', 'IPC Section Study'),
        ('legal_research', 'Legal Research'),
        
        # Authentication Activities
        ('login', 'User Login'),
        ('logout', 'User Logout'),
        ('profile_update', 'Profile Update'),
        
        # Dashboard Activities
        ('dashboard_view', 'Dashboard View'),
        ('analytics_view', 'Analytics View'),
        ('report_generation', 'Report Generation'),
    ]
    
    STATUS_CHOICES = [
        ('success', 'Success'),
        ('failed', 'Failed'),
        ('pending', 'Pending'),
        ('cancelled', 'Cancelled'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='activity_history')
    
    # Activity Details
    activity_type = models.CharField(max_length=50, choices=ACTIVITY_TYPES)
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    
    # Status and Results
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='success')
    result_data = models.JSONField(blank=True, null=True)  # Store analysis results, document info, etc.
    
    # Metadata
    ip_address = models.GenericIPAddressField(blank=True, null=True)
    user_agent = models.TextField(blank=True)
    session_id = models.CharField(max_length=255, blank=True)
    
    # File Information (if applicable)
    file_name = models.CharField(max_length=255, blank=True)
    file_size = models.PositiveIntegerField(blank=True, null=True)  # in bytes
    file_type = models.CharField(max_length=50, blank=True)
    
    # Timing
    created_at = models.DateTimeField(default=timezone.now)
    duration_seconds = models.PositiveIntegerField(blank=True, null=True)  # How long the activity took
    
    # Additional Context
    page_url = models.URLField(blank=True)
    referrer_url = models.URLField(blank=True)
    additional_data = models.JSONField(blank=True, null=True)  # For any extra context
    
    class Meta:
        db_table = 'user_activity_history'
        verbose_name = 'User Activity History'
        verbose_name_plural = 'User Activity Histories'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['activity_type', '-created_at']),
            models.Index(fields=['status', '-created_at']),
        ]
    
    def __str__(self):
        return f"{self.user.email} - {self.get_activity_type_display()} - {self.created_at}"
    
    @property
    def time_ago(self):
        """Get human-readable time difference"""
        now = timezone.now()
        diff = now - self.created_at
        
        if diff.days > 0:
            return f"{diff.days} day{'s' if diff.days > 1 else ''} ago"
        elif diff.seconds > 3600:
            hours = diff.seconds // 3600
            return f"{hours} hour{'s' if hours > 1 else ''} ago"
        elif diff.seconds > 60:
            minutes = diff.seconds // 60
            return f"{minutes} minute{'s' if minutes > 1 else ''} ago"
        else:
            return "Just now"
    
    @property
    def icon_name(self):
        """Get appropriate icon for the activity type"""
        icon_map = {
            'document_analysis': 'FileText',
            'case_analysis': 'Scale',
            'ipc_analysis': 'BookOpen',
            'case_creation': 'Plus',
            'case_update': 'Edit',
            'case_search': 'Search',
            'lawyer_search': 'Users',
            'lawyer_contact': 'Mail',
            'consultation_request': 'Calendar',
            'document_upload': 'Upload',
            'document_summarization': 'FileText',
            'document_download': 'Download',
            'legal_case_study': 'BookOpen',
            'ipc_section_study': 'Book',
            'legal_research': 'Search',
            'login': 'LogIn',
            'logout': 'LogOut',
            'profile_update': 'User',
            'dashboard_view': 'LayoutDashboard',
            'analytics_view': 'BarChart',
            'report_generation': 'FileBarChart',
        }
        return icon_map.get(self.activity_type, 'Activity')


class UserAnalyticsData(models.Model):
    """Model to store aggregated analytics data for users"""
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='analytics_data')
    
    # Activity Counts
    total_analyses = models.PositiveIntegerField(default=0)
    total_documents_processed = models.PositiveIntegerField(default=0)
    total_cases_created = models.PositiveIntegerField(default=0)
    total_lawyer_searches = models.PositiveIntegerField(default=0)
    total_legal_research = models.PositiveIntegerField(default=0)
    
    # Time Tracking
    total_time_spent_minutes = models.PositiveIntegerField(default=0)
    last_activity_date = models.DateTimeField(blank=True, null=True)
    
    # File Processing Stats
    total_files_uploaded = models.PositiveIntegerField(default=0)
    total_file_size_mb = models.FloatField(default=0.0)
    
    # Monthly Stats (current month)
    monthly_analyses = models.PositiveIntegerField(default=0)
    monthly_documents = models.PositiveIntegerField(default=0)
    monthly_cases = models.PositiveIntegerField(default=0)
    current_month = models.PositiveIntegerField(default=0)  # Store month for tracking
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'user_analytics_data'
        verbose_name = 'User Analytics Data'
        verbose_name_plural = 'User Analytics Data'
    
    def __str__(self):
        return f"Analytics for {self.user.email}"
    
    def update_analytics(self):
        """Update analytics based on user activity history"""
        from django.db.models import Count, Sum
        from datetime import datetime
        
        current_month = datetime.now().month
        
        # Reset monthly stats if month changed
        if self.current_month != current_month:
            self.monthly_analyses = 0
            self.monthly_documents = 0
            self.monthly_cases = 0
            self.current_month = current_month
        
        # Get activity counts
        activities = UserActivityHistory.objects.filter(user=self.user)
        
        self.total_analyses = activities.filter(
            activity_type__in=['document_analysis', 'case_analysis', 'ipc_analysis']
        ).count()
        
        self.total_documents_processed = activities.filter(
            activity_type__in=['document_upload', 'document_summarization']
        ).count()
        
        self.total_cases_created = activities.filter(activity_type='case_creation').count()
        self.total_lawyer_searches = activities.filter(activity_type='lawyer_search').count()
        self.total_legal_research = activities.filter(activity_type='legal_research').count()
        
        # Calculate total time spent
        total_duration = activities.aggregate(
            total=Sum('duration_seconds')
        )['total'] or 0
        self.total_time_spent_minutes = total_duration // 60
        
        # Calculate file stats
        file_activities = activities.filter(file_size__isnull=False)
        self.total_files_uploaded = file_activities.count()
        total_size_bytes = file_activities.aggregate(
            total=Sum('file_size')
        )['total'] or 0
        self.total_file_size_mb = total_size_bytes / (1024 * 1024)
        
        # Monthly stats
        from django.utils import timezone
        current_month_start = timezone.now().replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        monthly_activities = activities.filter(created_at__gte=current_month_start)
        
        self.monthly_analyses = monthly_activities.filter(
            activity_type__in=['document_analysis', 'case_analysis', 'ipc_analysis']
        ).count()
        
        self.monthly_documents = monthly_activities.filter(
            activity_type__in=['document_upload', 'document_summarization']
        ).count()
        
        self.monthly_cases = monthly_activities.filter(activity_type='case_creation').count()
        
        # Update last activity
        latest_activity = activities.first()
        if latest_activity:
            self.last_activity_date = latest_activity.created_at
        
        self.save()
