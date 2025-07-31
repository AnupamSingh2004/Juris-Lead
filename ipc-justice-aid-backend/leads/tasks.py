from celery import shared_task
from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)


@shared_task
def send_lead_notification(lead_id, lawyer_id):
    """Send email notification to lawyer about new matching lead"""
    try:
        from .models import CaseLead, LawyerProfile
        
        lead = CaseLead.objects.get(id=lead_id)
        lawyer = LawyerProfile.objects.get(id=lawyer_id)
        
        if not lawyer.email_notifications:
            return "Email notifications disabled for this lawyer"
        
        subject = f"New Case Lead: {lead.case_category.title()} in {lead.city}"
        
        message = f"""
        Dear {lawyer.user.get_full_name() or lawyer.user.username},

        A new case lead matching your practice areas has been posted:

        Case Category: {lead.case_category.title()}
        Location: {lead.city}, {lead.state}
        Urgency Level: {lead.urgency_level.title()}
        IPC Sections: {', '.join(lead.ipc_sections_identified)}

        Case Description:
        {lead.case_description[:300]}...

        To view the full details and express interest, please log in to your dashboard:
        {settings.FRONTEND_URL}/lawyer/dashboard/leads/{lead.lead_id}

        Best regards,
        IPC Justice Aid Team
        """
        
        send_mail(
            subject,
            message,
            settings.DEFAULT_FROM_EMAIL,
            [lawyer.user.email],
            fail_silently=False,
        )
        
        return f"Notification sent to {lawyer.user.email}"
        
    except Exception as e:
        logger.error(f"Failed to send lead notification: {str(e)}")
        return f"Failed: {str(e)}"


@shared_task
def cleanup_expired_leads():
    """Remove expired leads and their associated data"""
    try:
        from .models import CaseLead
        
        expired_leads = CaseLead.objects.filter(
            expires_at__lt=timezone.now(),
            status__in=['published', 'new']
        )
        
        count = expired_leads.count()
        expired_leads.update(status='closed')
        
        logger.info(f"Closed {count} expired leads")
        return f"Closed {count} expired leads"
        
    except Exception as e:
        logger.error(f"Failed to cleanup expired leads: {str(e)}")
        return f"Failed: {str(e)}"


@shared_task
def reset_monthly_subscription_limits():
    """Reset monthly lead consumption for all subscriptions (run monthly)"""
    try:
        from .models import Subscription
        
        subscriptions = Subscription.objects.filter(status='active')
        count = 0
        
        for subscription in subscriptions:
            subscription.reset_monthly_consumption()
            count += 1
        
        logger.info(f"Reset monthly limits for {count} subscriptions")
        return f"Reset monthly limits for {count} subscriptions"
        
    except Exception as e:
        logger.error(f"Failed to reset monthly limits: {str(e)}")
        return f"Failed: {str(e)}"


@shared_task
def generate_analytics_report():
    """Generate daily analytics report"""
    try:
        from .models import CaseLead, LawyerProfile, LeadAssignment
        from django.db.models import Count
        
        today = timezone.now().date()
        yesterday = today - timedelta(days=1)
        
        # Daily stats
        new_leads = CaseLead.objects.filter(created_at__date=yesterday).count()
        new_lawyers = LawyerProfile.objects.filter(created_at__date=yesterday).count()
        new_assignments = LeadAssignment.objects.filter(assigned_at__date=yesterday).count()
        
        # Weekly conversion rate
        week_ago = today - timedelta(days=7)
        weekly_leads = CaseLead.objects.filter(created_at__date__gte=week_ago)
        leads_with_interest = weekly_leads.filter(assigned_lawyers__isnull=False).distinct().count()
        conversion_rate = (leads_with_interest / weekly_leads.count() * 100) if weekly_leads.count() > 0 else 0
        
        report = f"""
        Daily Analytics Report - {yesterday}
        
        New Leads: {new_leads}
        New Lawyers: {new_lawyers}
        New Assignments: {new_assignments}
        
        Weekly Conversion Rate: {conversion_rate:.2f}%
        """
        
        # Send to admin email if configured
        if hasattr(settings, 'ADMIN_EMAIL') and settings.ADMIN_EMAIL:
            send_mail(
                f"IPC Justice Aid - Daily Report {yesterday}",
                report,
                settings.DEFAULT_FROM_EMAIL,
                [settings.ADMIN_EMAIL],
                fail_silently=True,
            )
        
        logger.info(f"Generated analytics report for {yesterday}")
        return report
        
    except Exception as e:
        logger.error(f"Failed to generate analytics report: {str(e)}")
        return f"Failed: {str(e)}"


@shared_task
def update_lead_analytics():
    """Update analytics for all active leads"""
    try:
        from .models import CaseLead, LeadAnalytics, LeadAssignment
        
        active_leads = CaseLead.objects.filter(
            status='published',
            expires_at__gt=timezone.now()
        )
        
        updated_count = 0
        
        for lead in active_leads:
            analytics, created = LeadAnalytics.objects.get_or_create(lead=lead)
            
            assignments = LeadAssignment.objects.filter(lead=lead)
            
            analytics.unique_lawyer_views = assignments.count()
            analytics.interested_lawyers_count = assignments.filter(action='interested').count()
            analytics.contacted_lawyers_count = assignments.filter(action='contacted').count()
            
            # Calculate geographic spread
            cities = list(assignments.values_list('lawyer__city', flat=True).distinct())
            analytics.lawyer_cities_interested = cities
            
            analytics.save()
            updated_count += 1
        
        logger.info(f"Updated analytics for {updated_count} leads")
        return f"Updated analytics for {updated_count} leads"
        
    except Exception as e:
        logger.error(f"Failed to update lead analytics: {str(e)}")
        return f"Failed: {str(e)}"
