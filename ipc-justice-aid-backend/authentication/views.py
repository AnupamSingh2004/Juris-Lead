from django.utils import timezone
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from django.contrib.auth import login
from django.shortcuts import get_object_or_404
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.cache import never_cache
import logging

from .models import User, OTPVerification, LoginAttempt, UserSession
from .serializers import (
    UserRegistrationSerializer,
    OTPVerificationSerializer,
    UserLoginSerializer,
    GoogleLoginSerializer,
    UserProfileSerializer,
    PasswordResetRequestSerializer,
    PasswordResetConfirmSerializer,
    ResendOTPSerializer,
    ChangePasswordSerializer
)
from .utils import (
    verify_google_token,
    log_login_attempt,
    get_client_ip,
    create_user_session,
    check_rate_limit,
    send_welcome_email
)

logger = logging.getLogger(__name__)


def get_tokens_for_user(user):
    """Generate JWT tokens for user"""
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


@api_view(['POST'])
@csrf_exempt
@permission_classes([])  # Allow unauthenticated access
def register_user(request):
    """User registration endpoint"""
    try:
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()

            # Log the registration
            logger.info(f"New user registered: {user.email}")

            return Response({
                'status': 'success',
                'message': 'Registration successful. Please check your email for OTP verification.',
                'data': {
                    'user_id': str(user.id),
                    'email': user.email,
                    'requires_verification': True
                }
            }, status=status.HTTP_201_CREATED)

        return Response({
            'status': 'error',
            'message': 'Registration failed',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        logger.error(f"Registration error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred during registration'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@csrf_exempt
@permission_classes([])  # Allow unauthenticated access
def verify_otp(request):
    """OTP verification endpoint"""
    try:
        serializer = OTPVerificationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()

            # Send welcome email after successful verification
            if serializer.validated_data['otp'].otp_type == 'email_verification':
                send_welcome_email(user)

            return Response({
                'status': 'success',
                'message': 'OTP verified successfully',
                'data': {
                    'user_id': str(user.id),
                    'email': user.email,
                    'verified': True
                }
            }, status=status.HTTP_200_OK)

        # Increment attempts for failed verification
        email = request.data.get('email')
        otp_code = request.data.get('otp_code')
        otp_type = request.data.get('otp_type')

        if email and otp_code and otp_type:
            try:
                user = User.objects.get(email=email)
                otp = OTPVerification.objects.filter(
                    user=user,
                    otp_code=otp_code,
                    otp_type=otp_type,
                    is_verified=False
                ).first()
                if otp:
                    otp.increment_attempts()
            except User.DoesNotExist:
                pass

        return Response({
            'status': 'error',
            'message': 'OTP verification failed',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        logger.error(f"OTP verification error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred during OTP verification'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@csrf_exempt
@permission_classes([])  # Allow unauthenticated access
def login_user(request):
    """User login endpoint"""
    try:
        email = request.data.get('email', '')

        # Check rate limiting
        if check_rate_limit(email, request):
            return Response({
                'status': 'error',
                'message': 'Too many failed login attempts. Please try again later.'
            }, status=status.HTTP_429_TOO_MANY_REQUESTS)

        serializer = UserLoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']

            # Log successful login
            log_login_attempt(email, request, success=True)

            # Create user session
            session_key = create_user_session(user, request)

            # Generate JWT tokens
            tokens = get_tokens_for_user(user)

            # Update last login
            user.last_login = timezone.now()
            user.save(update_fields=['last_login'])

            return Response({
                'status': 'success',
                'message': 'Login successful',
                'data': {
                    'tokens': tokens,
                    'user': UserProfileSerializer(user).data,
                    'session_key': session_key
                }
            }, status=status.HTTP_200_OK)

        # Log failed login
        log_login_attempt(email, request, success=False)

        return Response({
            'status': 'error',
            'message': 'Login failed',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        logger.error(f"Login error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred during login'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@csrf_exempt
@permission_classes([])  # Allow unauthenticated access
def google_login(request):
    """Google OAuth login endpoint"""
    try:
        serializer = GoogleLoginSerializer(data=request.data)
        if serializer.is_valid():
            access_token = serializer.validated_data['access_token']

            # Verify Google token
            google_user_data = verify_google_token(access_token)
            if not google_user_data:
                return Response({
                    'status': 'error',
                    'message': 'Invalid Google access token'
                }, status=status.HTTP_400_BAD_REQUEST)

            email = google_user_data['email']

            # Check if user exists
            user, created = User.objects.get_or_create(
                email=email,
                defaults={
                    'first_name': google_user_data['first_name'],
                    'last_name': google_user_data['last_name'],
                    'is_google_user': True,
                    'google_id': google_user_data['google_id'],
                    'email_verified': True,
                    'is_active': True
                }
            )

            # Update existing user if needed
            if not created and not user.is_google_user:
                user.is_google_user = True
                user.google_id = google_user_data['google_id']
                user.email_verified = True
                user.is_active = True
                user.save()

            # Log successful login
            log_login_attempt(email, request, success=True)

            # Create user session
            session_key = create_user_session(user, request)

            # Generate JWT tokens
            tokens = get_tokens_for_user(user)

            # Send welcome email for new users
            if created:
                send_welcome_email(user)

            return Response({
                'status': 'success',
                'message': 'Google login successful',
                'data': {
                    'tokens': tokens,
                    'user': UserProfileSerializer(user).data,
                    'session_key': session_key,
                    'is_new_user': created
                }
            }, status=status.HTTP_200_OK)

        return Response({
            'status': 'error',
            'message': 'Google login failed',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        logger.error(f"Google login error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred during Google login'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@csrf_exempt
@permission_classes([IsAuthenticated])
def logout_user(request):
    """User logout endpoint"""
    try:
        # Invalidate user sessions
        UserSession.objects.filter(user=request.user, is_active=True).update(is_active=False)

        return Response({
            'status': 'success',
            'message': 'Logout successful'
        }, status=status.HTTP_200_OK)

    except Exception as e:
        logger.error(f"Logout error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred during logout'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET', 'PUT'])
@csrf_exempt
@permission_classes([IsAuthenticated])
def user_profile(request):
    """Get or update user profile"""
    try:
        if request.method == 'GET':
            serializer = UserProfileSerializer(request.user)
            profile_data = serializer.data
            
            # Add prescription analytics
            try:
                from prescriptions.models import PrescriptionAnalytics
                analytics, created = PrescriptionAnalytics.objects.get_or_create(
                    user=request.user
                )
                if not created:
                    analytics.update_analytics()
                
                profile_data.update({
                    'total_savings': str(analytics.total_savings),
                    'medicines_searched': analytics.total_medicines_searched,
                    'stores_visited': analytics.stores_visited,
                    'schemes_applied': analytics.schemes_applied,
                })
            except ImportError:
                # Prescriptions app not available
                profile_data.update({
                    'total_savings': '0',
                    'medicines_searched': 0,
                    'stores_visited': 0,
                    'schemes_applied': 0,
                })
            
            return Response({
                'status': 'success',
                'data': profile_data
            }, status=status.HTTP_200_OK)

        elif request.method == 'PUT':
            serializer = UserProfileSerializer(request.user, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response({
                    'status': 'success',
                    'message': 'Profile updated successfully',
                    'data': serializer.data
                }, status=status.HTTP_200_OK)

            return Response({
                'status': 'error',
                'message': 'Profile update failed',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        logger.error(f"Profile error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@csrf_exempt
@permission_classes([])  # Allow unauthenticated access
def password_reset_request(request):
    """Request password reset OTP"""
    try:
        serializer = PasswordResetRequestSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()

            return Response({
                'status': 'success',
                'message': 'Password reset OTP sent to your email',
                'data': {
                    'email': user.email
                }
            }, status=status.HTTP_200_OK)

        return Response({
            'status': 'error',
            'message': 'Password reset request failed',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        logger.error(f"Password reset request error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@csrf_exempt
@permission_classes([])  # Allow unauthenticated access
def password_reset_confirm(request):
    """Confirm password reset with OTP"""
    try:
        serializer = PasswordResetConfirmSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()

            return Response({
                'status': 'success',
                'message': 'Password reset successful',
                'data': {
                    'email': user.email
                }
            }, status=status.HTTP_200_OK)

        return Response({
            'status': 'error',
            'message': 'Password reset failed',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        logger.error(f"Password reset confirm error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@csrf_exempt
@permission_classes([])  # Allow unauthenticated access
def resend_otp(request):
    """Resend OTP"""
    try:
        serializer = ResendOTPSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()

            return Response({
                'status': 'success',
                'message': 'OTP sent successfully',
                'data': {
                    'email': user.email
                }
            }, status=status.HTTP_200_OK)

        return Response({
            'status': 'error',
            'message': 'Failed to send OTP',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        logger.error(f"Resend OTP error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@csrf_exempt
@permission_classes([IsAuthenticated])
def change_password(request):
    """Change user password"""
    try:
        if request.user.is_google_user:
            return Response({
                'status': 'error',
                'message': 'Google users cannot change password'
            }, status=status.HTTP_400_BAD_REQUEST)

        serializer = ChangePasswordSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            user = serializer.save()

            return Response({
                'status': 'success',
                'message': 'Password changed successfully'
            }, status=status.HTTP_200_OK)

        return Response({
            'status': 'error',
            'message': 'Password change failed',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        logger.error(f"Change password error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@csrf_exempt
@permission_classes([IsAuthenticated])
def user_sessions(request):
    """Get user active sessions"""
    try:
        sessions = UserSession.objects.filter(user=request.user, is_active=True)
        sessions_data = []

        for session in sessions:
            sessions_data.append({
                'session_key': session.session_key[:8] + '...',
                'ip_address': session.ip_address,
                'user_agent': session.user_agent[:50] + '...' if len(session.user_agent) > 50 else session.user_agent,
                'created_at': session.created_at,
                'last_activity': session.last_activity
            })

        return Response({
            'status': 'success',
            'data': {
                'sessions': sessions_data,
                'total_sessions': len(sessions_data)
            }
        }, status=status.HTTP_200_OK)

    except Exception as e:
        logger.error(f"User sessions error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@csrf_exempt
@permission_classes([IsAuthenticated])
def revoke_session(request):
    """Revoke a specific session"""
    try:
        session_key = request.data.get('session_key')
        if not session_key:
            return Response({
                'status': 'error',
                'message': 'Session key is required'
            }, status=status.HTTP_400_BAD_REQUEST)

        session = UserSession.objects.filter(
            user=request.user,
            session_key=session_key,
            is_active=True
        ).first()

        if not session:
            return Response({
                'status': 'error',
                'message': 'Session not found'
            }, status=status.HTTP_404_NOT_FOUND)

        session.is_active = False
        session.save()

        return Response({
            'status': 'success',
            'message': 'Session revoked successfully'
        }, status=status.HTTP_200_OK)

    except Exception as e:
        logger.error(f"Revoke session error: {str(e)}")
        return Response({
            'status': 'error',
            'message': 'An error occurred'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@csrf_exempt
@permission_classes([])  # Allow unauthenticated access
def health_check(request):
    """Health check endpoint"""
    return Response({
        'status': 'success',
        'message': 'MediCare API is running',
        'timestamp': timezone.now()
    }, status=status.HTTP_200_OK)