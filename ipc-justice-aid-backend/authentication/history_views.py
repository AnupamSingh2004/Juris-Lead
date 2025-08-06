from rest_framework import status, generics, filters
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.pagination import PageNumberPagination
from django.utils import timezone
from django.db.models import Q, Count
from datetime import datetime, timedelta
import logging

from .history_models import UserActivityHistory, UserAnalyticsData
from .history_serializers import (
    UserActivityHistorySerializer, 
    UserAnalyticsDataSerializer,
    CreateActivitySerializer
)

logger = logging.getLogger(__name__)


class HistoryPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class UserHistoryListView(generics.ListAPIView):
    """List user's activity history with filtering and search"""
    serializer_class = UserActivityHistorySerializer
    permission_classes = [IsAuthenticated]
    pagination_class = HistoryPagination
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['title', 'description', 'file_name']
    ordering_fields = ['created_at', 'activity_type', 'status']
    ordering = ['-created_at']

    def get_queryset(self):
        queryset = UserActivityHistory.objects.filter(user=self.request.user)
        
        # Filter by activity type
        activity_type = self.request.query_params.get('activity_type')
        if activity_type:
            queryset = queryset.filter(activity_type=activity_type)
        
        # Filter by status
        activity_status = self.request.query_params.get('status')
        if activity_status:
            queryset = queryset.filter(status=activity_status)
        
        # Filter by date range
        date_from = self.request.query_params.get('date_from')
        date_to = self.request.query_params.get('date_to')
        
        if date_from:
            try:
                from_date = datetime.strptime(date_from, '%Y-%m-%d').date()
                queryset = queryset.filter(created_at__date__gte=from_date)
            except ValueError:
                pass
        
        if date_to:
            try:
                to_date = datetime.strptime(date_to, '%Y-%m-%d').date()
                queryset = queryset.filter(created_at__date__lte=to_date)
            except ValueError:
                pass
        
        # Filter by time period
        time_period = self.request.query_params.get('period')
        if time_period:
            now = timezone.now()
            if time_period == 'today':
                queryset = queryset.filter(created_at__date=now.date())
            elif time_period == 'week':
                week_ago = now - timedelta(days=7)
                queryset = queryset.filter(created_at__gte=week_ago)
            elif time_period == 'month':
                month_ago = now - timedelta(days=30)
                queryset = queryset.filter(created_at__gte=month_ago)
            elif time_period == 'year':
                year_ago = now - timedelta(days=365)
                queryset = queryset.filter(created_at__gte=year_ago)
        
        return queryset

    def list(self, request, *args, **kwargs):
        try:
            response = super().list(request, *args, **kwargs)
            
            # Add summary statistics
            queryset = self.get_queryset()
            total_count = queryset.count()
            
            # Activity type breakdown
            activity_breakdown = queryset.values('activity_type').annotate(
                count=Count('activity_type')
            ).order_by('-count')
            
            # Status breakdown
            status_breakdown = queryset.values('status').annotate(
                count=Count('status')
            ).order_by('-count')
            
            response.data['summary'] = {
                'total_activities': total_count,
                'activity_breakdown': list(activity_breakdown),
                'status_breakdown': list(status_breakdown)
            }
            
            return response
        except Exception as e:
            logger.error(f"Error listing user history: {str(e)}")
            return Response({
                'status': 'error',
                'message': 'Failed to retrieve history'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_activity_record(request):
    """Create a new activity record"""
    try:
        serializer = CreateActivitySerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            activity = serializer.save()
            
            # Update user analytics
            analytics, created = UserAnalyticsData.objects.get_or_create(user=request.user)
            analytics.update_analytics()
            
            return Response({
                'status': 'success',
                'message': 'Activity recorded successfully',
                'data': UserActivityHistorySerializer(activity).data
            }, status=status.HTTP_201_CREATED)
        
        return Response({
            'status': 'error',
            'message': 'Invalid activity data',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
        logger.error(f"Error creating activity record: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'Failed to record activity'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_analytics_summary(request):
    """Get user analytics summary"""
    try:
        analytics, created = UserAnalyticsData.objects.get_or_create(user=request.user)
        
        if created or not analytics.last_activity_date:
            analytics.update_analytics()
        
        serializer = UserAnalyticsDataSerializer(analytics)
        
        # Add recent activity trends
        now = timezone.now()
        
        # Last 7 days activity
        week_ago = now - timedelta(days=7)
        recent_activities = UserActivityHistory.objects.filter(
            user=request.user,
            created_at__gte=week_ago
        ).values('created_at__date').annotate(
            count=Count('id')
        ).order_by('created_at__date')
        
        # Most frequent activities
        top_activities = UserActivityHistory.objects.filter(
            user=request.user
        ).values('activity_type').annotate(
            count=Count('activity_type')
        ).order_by('-count')[:5]
        
        return Response({
            'status': 'success',
            'data': {
                'analytics': serializer.data,
                'recent_trend': list(recent_activities),
                'top_activities': list(top_activities)
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Error getting user analytics: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'Failed to retrieve analytics'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def activity_types_list(request):
    """Get list of available activity types"""
    try:
        activity_types = [
            {'value': choice[0], 'label': choice[1]} 
            for choice in UserActivityHistory.ACTIVITY_TYPES
        ]
        
        return Response({
            'status': 'success',
            'data': activity_types
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Error getting activity types: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'Failed to retrieve activity types'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def clear_user_history(request):
    """Clear user's activity history"""
    try:
        # Get optional date filter
        days = request.query_params.get('days')
        
        queryset = UserActivityHistory.objects.filter(user=request.user)
        
        if days:
            try:
                days_ago = timezone.now() - timedelta(days=int(days))
                queryset = queryset.filter(created_at__lte=days_ago)
            except (ValueError, TypeError):
                pass
        
        deleted_count = queryset.count()
        queryset.delete()
        
        # Update analytics after clearing history
        try:
            analytics = UserAnalyticsData.objects.get(user=request.user)
            analytics.update_analytics()
        except UserAnalyticsData.DoesNotExist:
            pass
        
        return Response({
            'status': 'success',
            'message': f'Cleared {deleted_count} activity records',
            'deleted_count': deleted_count
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Error clearing user history: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'Failed to clear history'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def export_user_history(request):
    """Export user history as JSON"""
    try:
        queryset = UserActivityHistory.objects.filter(user=request.user)
        
        # Apply same filters as list view
        activity_type = request.query_params.get('activity_type')
        if activity_type:
            queryset = queryset.filter(activity_type=activity_type)
        
        date_from = request.query_params.get('date_from')
        date_to = request.query_params.get('date_to')
        
        if date_from:
            try:
                from_date = datetime.strptime(date_from, '%Y-%m-%d').date()
                queryset = queryset.filter(created_at__date__gte=from_date)
            except ValueError:
                pass
        
        if date_to:
            try:
                to_date = datetime.strptime(date_to, '%Y-%m-%d').date()
                queryset = queryset.filter(created_at__date__lte=to_date)
            except ValueError:
                pass
        
        serializer = UserActivityHistorySerializer(queryset, many=True)
        
        return Response({
            'status': 'success',
            'data': serializer.data,
            'export_date': timezone.now().isoformat(),
            'total_records': queryset.count()
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Error exporting user history: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'Failed to export history'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
