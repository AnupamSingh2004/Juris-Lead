from django.db import models
from django.contrib.auth import get_user_model
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator
import uuid

User = get_user_model()


class LawyerProfile(models.Model):
    """Extended profile for lawyers"""
    PRACTICE_AREAS = [
        ('criminal', 'Criminal Law'),
        ('civil', 'Civil Law'),
        ('corporate', 'Corporate Law'),
        ('family', 'Family Law'),
        ('consumer', 'Consumer Protection'),
        ('cyber', 'Cyber Law'),
        ('tax', 'Tax Law'),
        ('labour', 'Labour Law'),
        ('intellectual_property', 'Intellectual Property'),
        ('environmental', 'Environmental Law'),
        ('human_rights', 'Human Rights'),
        ('other', 'Other'),
    ]
    
    EXPERIENCE_LEVELS = [
        ('junior', '0-2 years'),
        ('mid', '3-7 years'),
        ('senior', '8-15 years'),
        ('expert', '15+ years'),
    ]
    
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='lawyer_profile')
    bar_council_id = models.CharField(max_length=50, unique=True, help_text="Bar Council Registration ID")
    practice_areas = models.JSONField(default=list, help_text="List of practice areas")
    experience_level = models.CharField(max_length=20, choices=EXPERIENCE_LEVELS, default='junior')
    years_of_experience = models.IntegerField(default=0, validators=[MinValueValidator(0), MaxValueValidator(60)])
    
    # Location details
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    court_locations = models.JSONField(default=list, help_text="List of courts where they practice")
    
    # Professional details
    firm_name = models.CharField(max_length=200, blank=True, null=True)
    languages_spoken = models.JSONField(default=list, help_text="List of languages")
    consultation_fee = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    
    # Contact preferences
    email_notifications = models.BooleanField(default=True)
    sms_notifications = models.BooleanField(default=False)
    preferred_contact_time = models.CharField(max_length=50, blank=True, null=True)
    
    # Profile completion and verification
    profile_complete = models.BooleanField(default=False)
    verified = models.BooleanField(default=False)
    verification_documents = models.JSONField(default=dict, help_text="Verification document URLs")
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Lawyer: {self.user.get_full_name() or self.user.email}"
    
    def get_practice_areas_display(self):
        """Return human-readable practice areas"""
        area_dict = dict(self.PRACTICE_AREAS)
        return [area_dict.get(area, area) for area in self.practice_areas]


class Subscription(models.Model):
    """Subscription model for lawyers"""
    TIERS = [
        ('pro_bono', 'Pro-Bono (Free)'),
        ('solo_practitioner', 'Solo Practitioner'),
        ('small_firm', 'Small Firm'),
        ('enterprise', 'Enterprise'),
    ]
    
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('inactive', 'Inactive'),
        ('suspended', 'Suspended'),
        ('cancelled', 'Cancelled'),
    ]
    
    lawyer = models.OneToOneField(LawyerProfile, on_delete=models.CASCADE, related_name='subscription')
    tier = models.CharField(max_length=20, choices=TIERS, default='pro_bono')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    
    # Subscription limits
    monthly_lead_limit = models.IntegerField(default=5)
    current_month_leads_consumed = models.IntegerField(default=0)
    
    # Pricing
    monthly_price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    # Subscription period
    start_date = models.DateTimeField(auto_now_add=True)
    end_date = models.DateTimeField(null=True, blank=True)
    
    # Payment details
    razorpay_subscription_id = models.CharField(max_length=100, blank=True, null=True)
    last_payment_date = models.DateTimeField(null=True, blank=True)
    next_billing_date = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.lawyer.user.email} - {self.get_tier_display()}"
    
    def can_access_leads(self):
        """Check if lawyer can access more leads"""
        return (self.status == 'active' and 
                self.current_month_leads_consumed < self.monthly_lead_limit)
    
    def reset_monthly_consumption(self):
        """Reset monthly lead consumption (called by cron job)"""
        self.current_month_leads_consumed = 0
        self.save()


class CaseLead(models.Model):
    """Model for case leads generated from citizen platform"""
    STATUS_CHOICES = [
        ('new', 'New'),
        ('published', 'Published'),
        ('contacted', 'Contacted'),
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected'),
        ('closed', 'Closed'),
    ]
    
    URGENCY_LEVELS = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('critical', 'Critical'),
    ]
    
    # Lead identification
    lead_id = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    
    # Case details from citizen input
    case_description = models.TextField()
    incident_date = models.DateField(null=True, blank=True)
    incident_location = models.CharField(max_length=200)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    
    # AI Analysis results
    ai_analysis = models.JSONField(help_text="Analysis from IPC-Helper model")
    ipc_sections_identified = models.JSONField(default=list, help_text="List of IPC sections from AI")
    case_category = models.CharField(max_length=100, help_text="Primary case category from AI")
    urgency_level = models.CharField(max_length=20, choices=URGENCY_LEVELS, default='medium')
    
    # Contact information (anonymous)
    contact_method = models.CharField(max_length=20, choices=[
        ('email', 'Temporary Email'),
        ('telegram', 'Telegram ID'),
        ('phone', 'Temporary Phone'),
    ], default='email')
    contact_value = models.CharField(max_length=200, help_text="Anonymous contact information")
    
    # Lead management
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='new')
    assigned_lawyers = models.ManyToManyField(LawyerProfile, through='LeadAssignment', related_name='assigned_leads')
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    expires_at = models.DateTimeField(help_text="When this lead expires")
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['city', 'state']),
            models.Index(fields=['case_category']),
            models.Index(fields=['status']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"Lead {self.lead_id} - {self.case_category}"
    
    def get_matching_lawyers(self):
        """Get lawyers who might be interested in this case"""
        from django.db.models import Q
        
        # Filter by location and practice areas
        matching_lawyers = LawyerProfile.objects.filter(
            Q(city=self.city) | Q(state=self.state),
            profile_complete=True,
            verified=True,
            subscription__status='active'
        )
        
        # Further filter by practice areas if applicable
        if self.case_category:
            matching_lawyers = matching_lawyers.filter(
                practice_areas__contains=[self.case_category]
            )
        
        return matching_lawyers


class LeadAssignment(models.Model):
    """Through model for lead-lawyer assignments"""
    ACTION_CHOICES = [
        ('viewed', 'Viewed'),
        ('interested', 'Expressed Interest'),
        ('contacted', 'Contacted Client'),
        ('accepted', 'Accepted Case'),
        ('rejected', 'Rejected Case'),
    ]
    
    lead = models.ForeignKey(CaseLead, on_delete=models.CASCADE)
    lawyer = models.ForeignKey(LawyerProfile, on_delete=models.CASCADE)
    action = models.CharField(max_length=20, choices=ACTION_CHOICES, default='viewed')
    
    # Communication tracking
    lawyer_message = models.TextField(blank=True, help_text="Message from lawyer to client")
    client_response = models.TextField(blank=True, help_text="Response from client")
    
    # Timestamps
    assigned_at = models.DateTimeField(auto_now_add=True)
    last_action_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ['lead', 'lawyer']
        ordering = ['-last_action_at']
    
    def __str__(self):
        return f"{self.lawyer.user.email} - {self.lead.lead_id} ({self.action})"


class LawyerLeadFilter(models.Model):
    """Saved filters for lawyers to receive relevant leads"""
    lawyer = models.ForeignKey(LawyerProfile, on_delete=models.CASCADE, related_name='saved_filters')
    filter_name = models.CharField(max_length=100)
    
    # Filter criteria
    ipc_sections = models.JSONField(default=list, help_text="Preferred IPC sections")
    case_categories = models.JSONField(default=list, help_text="Preferred case categories")
    cities = models.JSONField(default=list, help_text="Preferred cities")
    urgency_levels = models.JSONField(default=list, help_text="Preferred urgency levels")
    
    # Notification preferences
    email_notifications = models.BooleanField(default=True)
    sms_notifications = models.BooleanField(default=False)
    real_time_notifications = models.BooleanField(default=True)
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.lawyer.user.email} - {self.filter_name}"


class LeadAnalytics(models.Model):
    """Analytics model to track lead performance"""
    lead = models.OneToOneField(CaseLead, on_delete=models.CASCADE, related_name='analytics')
    
    # View and interaction metrics
    total_views = models.IntegerField(default=0)
    unique_lawyer_views = models.IntegerField(default=0)
    interested_lawyers_count = models.IntegerField(default=0)
    contacted_lawyers_count = models.IntegerField(default=0)
    
    # Conversion metrics
    time_to_first_view = models.DurationField(null=True, blank=True)
    time_to_first_contact = models.DurationField(null=True, blank=True)
    time_to_acceptance = models.DurationField(null=True, blank=True)
    
    # Geographic spread
    lawyer_cities_interested = models.JSONField(default=list)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Analytics for {self.lead.lead_id}"


class CitizenFeedback(models.Model):
    """Feedback from citizens about the service"""
    RATING_CHOICES = [(i, str(i)) for i in range(1, 6)]
    
    lead = models.ForeignKey(CaseLead, on_delete=models.CASCADE, related_name='feedback')
    
    # Feedback content
    ai_analysis_rating = models.IntegerField(choices=RATING_CHOICES, help_text="Rating for AI analysis quality")
    lawyer_response_rating = models.IntegerField(choices=RATING_CHOICES, null=True, blank=True)
    overall_experience_rating = models.IntegerField(choices=RATING_CHOICES)
    
    comments = models.TextField(blank=True)
    would_recommend = models.BooleanField(default=True)
    
    # Improvement suggestions
    improvement_suggestions = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Feedback for {self.lead.lead_id} - {self.overall_experience_rating}/5"
