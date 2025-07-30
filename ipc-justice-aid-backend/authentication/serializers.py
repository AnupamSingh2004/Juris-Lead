from rest_framework import serializers
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from .models import User, OTPVerification
from .utils import send_otp_email, generate_otp
from django.utils import timezone
from datetime import timedelta
from django.conf import settings


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ('email', 'first_name', 'last_name', 'phone_number', 'password', 'password_confirm')

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError("Passwords don't match.")
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)

        # Generate and send OTP
        otp_code = generate_otp()
        expires_at = timezone.now() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES)

        OTPVerification.objects.create(
            user=user,
            otp_code=otp_code,
            otp_type='email_verification',
            expires_at=expires_at
        )

        send_otp_email(user.email, otp_code, 'email_verification')
        return user


class OTPVerificationSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp_code = serializers.CharField(max_length=10)
    otp_type = serializers.ChoiceField(choices=OTPVerification.OTP_TYPES)

    def validate(self, attrs):
        try:
            user = User.objects.get(email=attrs['email'])
            otp = OTPVerification.objects.filter(
                user=user,
                otp_code=attrs['otp_code'],
                otp_type=attrs['otp_type'],
                is_verified=False
            ).first()

            if not otp:
                raise serializers.ValidationError("Invalid OTP code.")

            if not otp.is_valid:
                raise serializers.ValidationError("OTP has expired or exceeded maximum attempts.")

            attrs['otp'] = otp
            attrs['user'] = user

        except User.DoesNotExist:
            raise serializers.ValidationError("User not found.")

        return attrs

    def save(self):
        otp = self.validated_data['otp']
        user = self.validated_data['user']

        otp.is_verified = True
        otp.save()

        if otp.otp_type == 'email_verification':
            user.email_verified = True
            user.is_active = True
            user.save()

        return user


class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')

        if email and password:
            user = authenticate(email=email, password=password)

            if not user:
                raise serializers.ValidationError("Invalid credentials.")

            if not user.is_active:
                raise serializers.ValidationError("Account is not active. Please verify your email.")

            if not user.email_verified and not user.is_google_user:
                raise serializers.ValidationError("Email not verified. Please verify your email first.")

            attrs['user'] = user
        else:
            raise serializers.ValidationError("Email and password are required.")

        return attrs


class GoogleLoginSerializer(serializers.Serializer):
    access_token = serializers.CharField()

    def validate_access_token(self, access_token):
        # This will be implemented in the view using Google's API
        return access_token


class UserProfileSerializer(serializers.ModelSerializer):
    full_name = serializers.ReadOnlyField()

    class Meta:
        model = User
        fields = (
            'id', 'email', 'first_name', 'last_name', 'full_name',
            'phone_number', 'date_of_birth', 'profile_picture',
            'email_verified', 'is_google_user', 'date_joined'
        )
        read_only_fields = ('id', 'email', 'email_verified', 'is_google_user', 'date_joined')


class PasswordResetRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, email):
        try:
            user = User.objects.get(email=email, is_active=True)
            if user.is_google_user:
                raise serializers.ValidationError("Google users cannot reset password. Please use Google Sign-In.")
        except User.DoesNotExist:
            raise serializers.ValidationError("User with this email does not exist.")
        return email

    def save(self):
        email = self.validated_data['email']
        user = User.objects.get(email=email)

        # Invalidate any existing password reset OTPs
        OTPVerification.objects.filter(
            user=user,
            otp_type='password_reset',
            is_verified=False
        ).update(is_verified=True)

        # Generate new OTP
        otp_code = generate_otp()
        expires_at = timezone.now() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES)

        OTPVerification.objects.create(
            user=user,
            otp_code=otp_code,
            otp_type='password_reset',
            expires_at=expires_at
        )

        send_otp_email(user.email, otp_code, 'password_reset')
        return user


class PasswordResetConfirmSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp_code = serializers.CharField(max_length=10)
    new_password = serializers.CharField(write_only=True, validators=[validate_password])
    new_password_confirm = serializers.CharField(write_only=True)

    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError("Passwords don't match.")

        try:
            user = User.objects.get(email=attrs['email'])
            otp = OTPVerification.objects.filter(
                user=user,
                otp_code=attrs['otp_code'],
                otp_type='password_reset',
                is_verified=False
            ).first()

            if not otp:
                raise serializers.ValidationError("Invalid OTP code.")

            if not otp.is_valid:
                raise serializers.ValidationError("OTP has expired or exceeded maximum attempts.")

            attrs['otp'] = otp
            attrs['user'] = user

        except User.DoesNotExist:
            raise serializers.ValidationError("User not found.")

        return attrs

    def save(self):
        otp = self.validated_data['otp']
        user = self.validated_data['user']
        new_password = self.validated_data['new_password']

        # Mark OTP as verified
        otp.is_verified = True
        otp.save()

        # Set new password
        user.set_password(new_password)
        user.save()

        return user


class ResendOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp_type = serializers.ChoiceField(choices=OTPVerification.OTP_TYPES)

    def validate(self, attrs):
        try:
            user = User.objects.get(email=attrs['email'])
            attrs['user'] = user
        except User.DoesNotExist:
            raise serializers.ValidationError("User not found.")
        return attrs

    def save(self):
        user = self.validated_data['user']
        otp_type = self.validated_data['otp_type']

        # Invalidate existing OTPs of the same type
        OTPVerification.objects.filter(
            user=user,
            otp_type=otp_type,
            is_verified=False
        ).update(is_verified=True)

        # Generate new OTP
        otp_code = generate_otp()
        expires_at = timezone.now() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES)

        OTPVerification.objects.create(
            user=user,
            otp_code=otp_code,
            otp_type=otp_type,
            expires_at=expires_at
        )

        send_otp_email(user.email, otp_code, otp_type)
        return user


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, validators=[validate_password])
    new_password_confirm = serializers.CharField(write_only=True)

    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError("New passwords don't match.")
        return attrs

    def validate_old_password(self, old_password):
        user = self.context['request'].user
        if not user.check_password(old_password):
            raise serializers.ValidationError("Old password is incorrect.")
        return old_password

    def save(self):
        user = self.context['request'].user
        user.set_password(self.validated_data['new_password'])
        user.save()
        return user