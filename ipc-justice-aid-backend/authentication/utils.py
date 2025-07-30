import random
import string
import requests
from django.core.mail import send_mail
from django.conf import settings
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token
import logging

logger = logging.getLogger(__name__)


def generate_otp(length=None):
    """Generate a random OTP code"""
    if length is None:
        length = settings.OTP_LENGTH
    return ''.join(random.choices(string.digits, k=length))


def send_otp_email(email, otp_code, otp_type):
    """Send OTP via email"""
    subject_map = {
        'email_verification': 'Verify Your MediCare Account',
        'password_reset': 'Reset Your MediCare Password',
        'login_verification': 'MediCare Login Verification'
    }

    template_map = {
        'email_verification': 'emails/email_verification.html',
        'password_reset': 'emails/password_reset.html',
        'login_verification': 'emails/login_verification.html'
    }

    subject = subject_map.get(otp_type, 'MediCare Verification Code')
    template_name = template_map.get(otp_type, 'emails/default_otp.html')

    try:
        # Render HTML email template
        context = {
            'otp_code': otp_code,
            'email': email,
            'expiry_minutes': settings.OTP_EXPIRY_MINUTES
        }

        html_message = render_to_string(template_name, context)
        plain_message = strip_tags(html_message)

        send_mail(
            subject=subject,
            message=plain_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[email],
            html_message=html_message,
            fail_silently=False,
        )

        logger.info(f"OTP email sent successfully to {email}")
        return True

    except Exception as e:
        logger.error(f"Failed to send OTP email to {email}: {str(e)}")
        return False


def verify_google_token(access_token):
    """Verify Google access token and return user info"""
    try:
        # Get user info from Google
        google_user_info_url = 'https://www.googleapis.com/oauth2/v2/userinfo'
        response = requests.get(
            google_user_info_url,
            params={'access_token': access_token}
        )

        if response.status_code == 200:
            user_data = response.json()
            return {
                'email': user_data.get('email'),
                'first_name': user_data.get('given_name', ''),
                'last_name': user_data.get('family_name', ''),
                'google_id': user_data.get('id'),
                'profile_picture_url': user_data.get('picture'),
                'email_verified': user_data.get('verified_email', False)
            }
        else:
            logger.error(f"Google token verification failed: {response.text}")
            return None

    except Exception as e:
        logger.error(f"Error verifying Google token: {str(e)}")
        return None


def get_client_ip(request):
    """Get client IP address from request"""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def get_user_agent(request):
    """Get user agent from request"""
    return request.META.get('HTTP_USER_AGENT', '')


def create_user_session(user, request):
    """Create a new user session record"""
    from .models import UserSession
    import uuid

    session_key = str(uuid.uuid4())

    UserSession.objects.create(
        user=user,
        session_key=session_key,
        ip_address=get_client_ip(request),
        user_agent=get_user_agent(request)
    )

    return session_key


def log_login_attempt(email, request, success=False):
    """Log login attempt"""
    from .models import LoginAttempt

    LoginAttempt.objects.create(
        email=email,
        ip_address=get_client_ip(request),
        user_agent=get_user_agent(request),
        success=success
    )


def validate_password_strength(password):
    """Validate password strength with custom rules"""
    errors = []

    if len(password) < 8:
        errors.append("Password must be at least 8 characters long.")

    if not any(char.isupper() for char in password):
        errors.append("Password must contain at least one uppercase letter.")

    if not any(char.islower() for char in password):
        errors.append("Password must contain at least one lowercase letter.")

    if not any(char.isdigit() for char in password):
        errors.append("Password must contain at least one digit.")

    special_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?"
    if not any(char in special_chars for char in password):
        errors.append("Password must contain at least one special character.")

    return errors


def clean_expired_otps():
    """Clean up expired OTP records"""
    from django.utils import timezone
    from .models import OTPVerification

    expired_count = OTPVerification.objects.filter(
        expires_at__lt=timezone.now()
    ).delete()[0]

    logger.info(f"Cleaned up {expired_count} expired OTP records")
    return expired_count


def clean_old_login_attempts(days=30):
    """Clean up old login attempt records"""
    from django.utils import timezone
    from datetime import timedelta
    from .models import LoginAttempt

    cutoff_date = timezone.now() - timedelta(days=days)
    deleted_count = LoginAttempt.objects.filter(
        created_at__lt=cutoff_date
    ).delete()[0]

    logger.info(f"Cleaned up {deleted_count} old login attempt records")
    return deleted_count


def check_rate_limit(email, request, window_minutes=15, max_attempts=5):
    """Check if user has exceeded rate limit for failed login attempts"""
    from django.utils import timezone
    from datetime import timedelta
    from .models import LoginAttempt

    window_start = timezone.now() - timedelta(minutes=window_minutes)

    recent_failed_attempts = LoginAttempt.objects.filter(
        email=email,
        ip_address=get_client_ip(request),
        success=False,
        created_at__gte=window_start
    ).count()

    return recent_failed_attempts >= max_attempts


def generate_username_from_email(email):
    """Generate a unique username from email"""
    base_username = email.split('@')[0]
    base_username = ''.join(char for char in base_username if char.isalnum())

    from .models import User
    username = base_username
    counter = 1

    while User.objects.filter(username=username).exists():
        username = f"{base_username}{counter}"
        counter += 1

    return username


def send_welcome_email(user):
    """Send welcome email to new users"""
    try:
        subject = 'Welcome to MediCare!'

        context = {
            'user': user,
            'first_name': user.first_name or 'User'
        }

        html_message = render_to_string('emails/welcome.html', context)
        plain_message = strip_tags(html_message)

        send_mail(
            subject=subject,
            message=plain_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            html_message=html_message,
            fail_silently=True,
        )

        logger.info(f"Welcome email sent to {user.email}")
        return True

    except Exception as e:
        logger.error(f"Failed to send welcome email to {user.email}: {str(e)}")
        return False