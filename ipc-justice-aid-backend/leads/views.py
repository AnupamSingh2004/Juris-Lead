from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from django.utils import timezone
from django.db.models import Q, Count
from django.core.exceptions import ValidationError
from django.conf import settings
from datetime import timedelta, datetime
import logging

from authentication.permissions import IsLawyerUser, IsClientUser, IsLawyerOrReadOnly

from .models import (
    LawyerProfile, Subscription, CaseLead, LeadAssignment,
    LawyerLeadFilter, LeadAnalytics, CitizenFeedback
)
from .serializers import (
    LawyerProfileSerializer, SubscriptionSerializer, CaseLeadSerializer,
    CaseLeadDetailSerializer, LeadAssignmentSerializer, LawyerLeadFilterSerializer,
    CitizenFeedbackSerializer, CaseAnalysisRequestSerializer,
    CaseAnalysisResponseSerializer, LawyerDashboardStatsSerializer
)
from .services import OllamaIPCService, LeadMatchingService, PDFReportService

logger = logging.getLogger(__name__)


class CitizenCaseAnalysisView(APIView):
    """
    Free public endpoint for citizens to analyze their legal cases
    """
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        """Analyze a legal case and optionally create a lead"""
        serializer = CaseAnalysisRequestSerializer(data=request.data)
        
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        data = serializer.validated_data
        
        try:
            # Initialize the IPC service
            logger.info("Initializing OllamaIPCService for case analysis")
            ipc_service = OllamaIPCService()
            
            logger.info(f"Starting case analysis for description: {data['case_description'][:100]}...")
            logger.info("This may take up to 5 minutes for AI processing...")
            
            # Analyze the case - this may take up to 5 minutes
            ai_analysis = ipc_service.analyze_case(
                case_description=data['case_description'],
                incident_date=data.get('incident_date'),
                location=data.get('incident_location')
            )
            
            logger.info("Case analysis completed successfully")
            logger.info(f"Analysis result keys: {list(ai_analysis.keys()) if ai_analysis else 'None'}")
            
            # Create case lead if user wants lawyer connect
            create_lead = data.get('create_lead', False)
            lead_id = None
            
            if create_lead:
                # Create the case lead
                case_lead = CaseLead.objects.create(
                    case_description=data['case_description'],
                    incident_date=data.get('incident_date'),
                    incident_location=data['incident_location'],
                    city=data['city'],
                    state=data['state'],
                    ai_analysis=ai_analysis,
                    ipc_sections_identified=ai_analysis.get('section_numbers_list', []),
                    case_category=ai_analysis.get('case_category', 'general'),
                    urgency_level=data.get('urgency_level', 'medium'),
                    contact_method=data['contact_method'],
                    contact_value=data['contact_value'],
                    expires_at=timezone.now() + timedelta(days=30)  # 30 days expiry
                )
                
                lead_id = case_lead.lead_id
                
                # Create analytics record
                LeadAnalytics.objects.create(lead=case_lead)
                
                # Find and notify matching lawyers
                matching_lawyers = LeadMatchingService.find_matching_lawyers(case_lead)
                LeadMatchingService.notify_matching_lawyers(case_lead, matching_lawyers)
                
                # Update lead status
                case_lead.status = 'published'
                case_lead.save()
            
            # Generate PDF report if requested
            pdf_url = None
            if data.get('generate_pdf', False) and lead_id:
                try:
                    pdf_filename = PDFReportService.generate_case_report(case_lead, ai_analysis)
                    pdf_url = f"/media/reports/{pdf_filename}"
                except Exception as e:
                    logger.error(f"PDF generation failed: {str(e)}")
            
            # Prepare clean response for frontend - support both old and new formats
            ipc_sections = ai_analysis.get('applicable_ipc_sections', ai_analysis.get('ipc_sections', []))
            
            # Clean up the IPC sections to only include required fields
            cleaned_sections = []
            for section in ipc_sections:
                cleaned_section = {
                    'section_number': section.get('section_number', ''),
                    'description': section.get('description', ''),
                    'why_applicable': section.get('why_applicable', section.get('why_applied', ''))
                }
                cleaned_sections.append(cleaned_section)
            
            response_data = {
                'applicable_ipc_sections': cleaned_sections,
                'severity': ai_analysis.get('severity', 'Medium'),
                'total_sections_identified': len(cleaned_sections),
                'analysis_timestamp': timezone.now().isoformat(),
            }
            
            # Remove None values to clean up response
            response_data = {k: v for k, v in response_data.items() if v is not None}
            
            return Response(response_data, status=status.HTTP_200_OK)
                
        except Exception as e:
            logger.error(f"Case analysis failed: {str(e)}", exc_info=True)
            
            # Return a helpful error message based on the type of error
            if "timeout" in str(e).lower() or "timed out" in str(e).lower():
                error_message = "Analysis is taking longer than expected. Please try again in a few minutes."
                error_data = {
                    "applicable_ipc_sections": [
                        {
                            "section_number": "TIMEOUT",
                            "section_title": "Request Timeout",
                            "description": "The legal analysis request took longer than expected to process.",
                            "why_applicable": "Processing time exceeded the maximum allowed duration",
                            "punishment": "N/A - Please retry the request"
                        }
                    ],
                    "case_summary": "Analysis timed out. Please try again.",
                    "severity": "Unknown",
                    "case_type": "Unknown"
                }
            elif "connection" in str(e).lower():
                error_message = "Unable to connect to analysis service. Please try again later."
                error_data = {
                    "applicable_ipc_sections": [
                        {
                            "section_number": "CONNECTION_ERROR",
                            "section_title": "Service Connection Error",
                            "description": "Unable to connect to the legal analysis service.",
                            "why_applicable": "Network or service connectivity issue",
                            "punishment": "N/A - Please retry the request"
                        }
                    ],
                    "case_summary": "Connection error occurred during analysis.",
                    "severity": "Unknown",
                    "case_type": "Unknown"
                }
            else:
                error_message = "Failed to analyze case. Please try again later or consult a lawyer directly."
                error_data = {
                    "applicable_ipc_sections": [
                        {
                            "section_number": "ANALYSIS_ERROR",
                            "section_title": "Analysis Error",
                            "description": "An error occurred during legal case analysis.",
                            "why_applicable": "Technical issue prevented analysis completion",
                            "punishment": "N/A - Please consult a legal expert"
                        }
                    ],
                    "case_summary": "Analysis could not be completed due to technical issues.",
                    "severity": "Unknown",
                    "case_type": "Unknown"
                }
            
            error_response = {
                **error_data,
                'analysis_timestamp': timezone.now().isoformat(),
                'total_sections_identified': len(error_data['applicable_ipc_sections']),
                'lead_id': None,
                'lawyer_connect_available': False,
                'pdf_report_url': None,
                'error': error_message,
                'details': str(e) if settings.DEBUG else None,
                'retry_suggested': True,
                'note': 'Analysis failed. Please try again or consult a qualified lawyer for legal advice.'
            }
            
            return Response(error_response, status=status.HTTP_200_OK)  # Return 200 with error info instead of 500


class LawyerProfileViewSet(viewsets.ModelViewSet):
    """ViewSet for lawyer profile management"""
    serializer_class = LawyerProfileSerializer
    permission_classes = [IsLawyerUser]
    
    def get_queryset(self):
        return LawyerProfile.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def complete_profile(self, request, pk=None):
        """Mark profile as complete after validation"""
        profile = self.get_object()
        
        # Validate required fields
        required_fields = ['bar_council_id', 'practice_areas', 'city', 'state', 'years_of_experience']
        missing_fields = []
        
        for field in required_fields:
            if not getattr(profile, field):
                missing_fields.append(field)
        
        if missing_fields:
            return Response({
                'error': 'Profile incomplete',
                'missing_fields': missing_fields
            }, status=status.HTTP_400_BAD_REQUEST)
        
        profile.profile_complete = True
        profile.save()
        
        return Response({'message': 'Profile completed successfully'})


class SubscriptionViewSet(viewsets.ModelViewSet):
    """ViewSet for subscription management"""
    serializer_class = SubscriptionSerializer
    permission_classes = [IsLawyerUser]
    
    def get_queryset(self):
        try:
            lawyer_profile = LawyerProfile.objects.get(user=self.request.user)
            return Subscription.objects.filter(lawyer=lawyer_profile)
        except LawyerProfile.DoesNotExist:
            return Subscription.objects.none()
    
    @action(detail=False, methods=['post'])
    def upgrade_subscription(self, request):
        """Upgrade lawyer's subscription tier"""
        try:
            lawyer_profile = LawyerProfile.objects.get(user=request.user)
            subscription = lawyer_profile.subscription
        except (LawyerProfile.DoesNotExist, Subscription.DoesNotExist):
            return Response({
                'error': 'Lawyer profile or subscription not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        new_tier = request.data.get('tier')
        if new_tier not in dict(Subscription.TIERS):
            return Response({
                'error': 'Invalid subscription tier'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Update subscription details based on tier
        tier_config = {
            'pro_bono': {'limit': 5, 'price': 0},
            'solo_practitioner': {'limit': 25, 'price': 2000},
            'small_firm': {'limit': 100, 'price': 8000},
            'enterprise': {'limit': 1000, 'price': 25000},
        }
        
        config = tier_config.get(new_tier, tier_config['pro_bono'])
        
        subscription.tier = new_tier
        subscription.monthly_lead_limit = config['limit']
        subscription.monthly_price = config['price']
        subscription.save()
        
        return Response({
            'message': f'Subscription upgraded to {new_tier}',
            'new_limit': config['limit'],
            'new_price': config['price']
        })


class CaseLeadViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for lawyers to view and interact with case leads"""
    permission_classes = [IsLawyerUser]
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return CaseLeadDetailSerializer
        return CaseLeadSerializer
    
    def get_queryset(self):
        try:
            lawyer_profile = LawyerProfile.objects.get(user=self.request.user)
            
            # Base queryset - published leads that haven't expired
            queryset = CaseLead.objects.filter(
                status='published',
                expires_at__gt=timezone.now()
            )
            
            # Apply filters based on lawyer's location and practice areas
            queryset = queryset.filter(
                Q(city=lawyer_profile.city) | Q(state=lawyer_profile.state)
            )
            
            # Filter by practice areas
            if lawyer_profile.practice_areas:
                queryset = queryset.filter(
                    case_category__in=lawyer_profile.practice_areas
                )
            
            # Apply search filters from query params
            search = self.request.query_params.get('search')
            if search:
                queryset = queryset.filter(
                    Q(case_description__icontains=search) |
                    Q(case_category__icontains=search)
                )
            
            # Filter by IPC sections
            ipc_sections = self.request.query_params.get('ipc_sections')
            if ipc_sections:
                sections_list = [s.strip() for s in ipc_sections.split(',')]
                queryset = queryset.filter(
                    ipc_sections_identified__overlap=sections_list
                )
            
            # Filter by urgency
            urgency = self.request.query_params.get('urgency')
            if urgency:
                queryset = queryset.filter(urgency_level=urgency)
            
            # Filter by city
            city = self.request.query_params.get('city')
            if city:
                queryset = queryset.filter(city__icontains=city)
            
            return queryset.order_by('-created_at')
            
        except LawyerProfile.DoesNotExist:
            return CaseLead.objects.none()
    
    @action(detail=True, methods=['post'])
    def express_interest(self, request, pk=None):
        """Express interest in a case lead"""
        lead = self.get_object()
        
        try:
            lawyer_profile = LawyerProfile.objects.get(user=request.user)
        except LawyerProfile.DoesNotExist:
            return Response({
                'error': 'Lawyer profile not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Check subscription limits
        if not lawyer_profile.subscription.can_access_leads():
            return Response({
                'error': 'Monthly lead limit exceeded',
                'message': 'Please upgrade your subscription to access more leads'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Check if already expressed interest
        assignment, created = LeadAssignment.objects.get_or_create(
            lead=lead,
            lawyer=lawyer_profile,
            defaults={
                'action': 'interested',
                'lawyer_message': request.data.get('message', '')
            }
        )
        
        if not created:
            return Response({
                'error': 'Already expressed interest in this lead'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Update subscription consumption
        lawyer_profile.subscription.current_month_leads_consumed += 1
        lawyer_profile.subscription.save()
        
        # Update lead analytics
        analytics = lead.analytics
        analytics.interested_lawyers_count += 1
        analytics.save()
        
        return Response({
            'message': 'Interest expressed successfully',
            'assignment_id': assignment.id
        })
    
    @action(detail=True, methods=['post'])
    def contact_client(self, request, pk=None):
        """Send message to client through the lead"""
        lead = self.get_object()
        
        try:
            lawyer_profile = LawyerProfile.objects.get(user=request.user)
            assignment = LeadAssignment.objects.get(lead=lead, lawyer=lawyer_profile)
        except (LawyerProfile.DoesNotExist, LeadAssignment.DoesNotExist):
            return Response({
                'error': 'No assignment found for this lead'
            }, status=status.HTTP_404_NOT_FOUND)
        
        message = request.data.get('message')
        if not message:
            return Response({
                'error': 'Message is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Update assignment
        assignment.action = 'contacted'
        assignment.lawyer_message = message
        assignment.save()
        
        # Update analytics
        analytics = lead.analytics
        if assignment.action != 'contacted':  # First contact
            analytics.contacted_lawyers_count += 1
            analytics.save()
        
        # Here you would typically send an email/notification to the client
        # For now, we'll just return success
        
        return Response({
            'message': 'Message sent to client successfully'
        })


class LawyerDashboardView(APIView):
    """Dashboard view for lawyers with statistics and metrics"""
    permission_classes = [IsLawyerUser]
    
    def get(self, request):
        try:
            lawyer_profile = LawyerProfile.objects.get(user=request.user)
        except LawyerProfile.DoesNotExist:
            return Response({
                'error': 'Lawyer profile not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Calculate statistics
        assignments = LeadAssignment.objects.filter(lawyer=lawyer_profile)
        
        today = timezone.now().date()
        current_month_start = today.replace(day=1)
        
        stats = {
            'total_leads_viewed': assignments.count(),
            'leads_contacted': assignments.filter(action='contacted').count(),
            'leads_accepted': assignments.filter(action='accepted').count(),
            'leads_rejected': assignments.filter(action='rejected').count(),
            'current_month_consumption': lawyer_profile.subscription.current_month_leads_consumed,
            'monthly_limit': lawyer_profile.subscription.monthly_lead_limit,
            'subscription_status': lawyer_profile.subscription.status,
            'new_leads_today': CaseLead.objects.filter(
                created_at__date=today,
                city=lawyer_profile.city
            ).count(),
            'pending_responses': assignments.filter(
                action='interested',
                client_response__isnull=True
            ).count(),
        }
        
        serializer = LawyerDashboardStatsSerializer(data=stats)
        if serializer.is_valid():
            return Response(serializer.validated_data)
        else:
            return Response(stats)


class LeadAnalyticsView(APIView):
    """Analytics view for lead performance (admin only)"""
    permission_classes = [permissions.IsAdminUser]
    
    def get(self, request):
        """Get system-wide lead analytics"""
        
        # Time filters
        days = int(request.query_params.get('days', 30))
        start_date = timezone.now() - timedelta(days=days)
        
        # Lead statistics
        total_leads = CaseLead.objects.filter(created_at__gte=start_date).count()
        published_leads = CaseLead.objects.filter(
            created_at__gte=start_date,
            status='published'
        ).count()
        
        # Conversion statistics
        leads_with_interest = CaseLead.objects.filter(
            created_at__gte=start_date,
            assigned_lawyers__isnull=False
        ).distinct().count()
        
        # Popular IPC sections
        popular_sections = {}
        leads = CaseLead.objects.filter(created_at__gte=start_date)
        for lead in leads:
            for section in lead.ipc_sections_identified:
                popular_sections[section] = popular_sections.get(section, 0) + 1
        
        # Geographic distribution
        geographic_data = CaseLead.objects.filter(
            created_at__gte=start_date
        ).values('state', 'city').annotate(count=Count('id')).order_by('-count')
        
        return Response({
            'period_days': days,
            'total_leads': total_leads,
            'published_leads': published_leads,
            'leads_with_interest': leads_with_interest,
            'conversion_rate': (leads_with_interest / total_leads * 100) if total_leads > 0 else 0,
            'popular_ipc_sections': dict(sorted(popular_sections.items(), key=lambda x: x[1], reverse=True)[:10]),
            'geographic_distribution': list(geographic_data[:20]),
        })


class SystemHealthView(APIView):
    """System health check including Ollama model status"""
    permission_classes = [permissions.AllowAny]
    
    def get(self, request):
        """Check system health"""
        health_data = {
            'status': 'healthy',
            'timestamp': timezone.now().isoformat(),
            'services': {}
        }
        
        # Check database
        try:
            CaseLead.objects.count()
            health_data['services']['database'] = 'healthy'
        except Exception as e:
            health_data['services']['database'] = f'error: {str(e)}'
            health_data['status'] = 'degraded'
        
        # Check Ollama service
        try:
            ipc_service = OllamaIPCService()
            is_connected, message = ipc_service.test_connection()
            health_data['services']['ollama'] = 'healthy' if is_connected else f'error: {message}'
            if not is_connected:
                health_data['status'] = 'degraded'
        except Exception as e:
            health_data['services']['ollama'] = f'error: {str(e)}'
            health_data['status'] = 'degraded'
        
        # Overall system stats
        if request.user.is_authenticated and request.user.is_staff:
            health_data['stats'] = {
                'total_leads': CaseLead.objects.count(),
                'active_lawyers': LawyerProfile.objects.filter(
                    subscription__status='active'
                ).count(),
                'leads_today': CaseLead.objects.filter(
                    created_at__date=timezone.now().date()
                ).count(),
            }
        
        status_code = status.HTTP_200_OK if health_data['status'] == 'healthy' else status.HTTP_503_SERVICE_UNAVAILABLE
        return Response(health_data, status=status_code)
