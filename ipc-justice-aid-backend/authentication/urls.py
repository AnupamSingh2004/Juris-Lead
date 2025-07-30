from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

app_name = 'authentication'

urlpatterns = [
    path('health/', views.health_check, name='health_check'),

    path('register/', views.register_user, name='register'),
    path('verify-otp/', views.verify_otp, name='verify_otp'),
    path('login/', views.login_user, name='login'),
    path('google-login/', views.google_login, name='google_login'),
    path('logout/', views.logout_user, name='logout'),

    # JWT token endpoints
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # Password management
    path('password-reset/request/', views.password_reset_request, name='password_reset_request'),
    path('password-reset/confirm/', views.password_reset_confirm, name='password_reset_confirm'),
    path('change-password/', views.change_password, name='change_password'),

    # OTP management
    path('resend-otp/', views.resend_otp, name='resend_otp'),

    # User profile
    path('profile/', views.user_profile, name='user_profile'),

    # Session management
    path('sessions/', views.user_sessions, name='user_sessions'),
    path('sessions/revoke/', views.revoke_session, name='revoke_session'),
]