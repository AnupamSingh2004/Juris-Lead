from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

# Create router for ViewSets
router = DefaultRouter()
router.register(r'lawyer-profiles', views.LawyerProfileViewSet, basename='lawyer-profile')
router.register(r'subscriptions', views.SubscriptionViewSet, basename='subscription')
router.register(r'leads', views.CaseLeadViewSet, basename='case-lead')

# URL patterns
urlpatterns = [
    # Public endpoints for citizens
    path('analyze-case/', views.CitizenCaseAnalysisView.as_view(), name='analyze-case'),
    
    # Lawyer dashboard
    path('dashboard/', views.LawyerDashboardView.as_view(), name='lawyer-dashboard'),
    
    # Analytics (admin only)
    path('analytics/', views.LeadAnalyticsView.as_view(), name='lead-analytics'),
    
    # System health
    path('health/', views.SystemHealthView.as_view(), name='system-health'),
    
    # Include router URLs
    path('', include(router.urls)),
]
