from django.urls import path
from .history_views import (
    UserHistoryListView,
    create_activity_record,
    user_analytics_summary,
    activity_types_list,
    clear_user_history,
    export_user_history
)

app_name = 'history'

urlpatterns = [
    # History endpoints
    path('activities/', UserHistoryListView.as_view(), name='user_activities'),
    path('activities/create/', create_activity_record, name='create_activity'),
    path('activities/types/', activity_types_list, name='activity_types'),
    path('activities/clear/', clear_user_history, name='clear_history'),
    path('activities/export/', export_user_history, name='export_history'),
    
    # Analytics endpoints
    path('analytics/', user_analytics_summary, name='user_analytics'),
]
