# ======================
# Django Backend (Core Files)
# ======================

# models.py
from django.contrib.auth.models import User
from django.db import models

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    location = models.CharField(max_length=255)

class HealthJourney(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    total_savings = models.DecimalField(max_digits=10, decimal_places=2, default=0.0)
    medicines_searched = models.IntegerField(default=0)
    stores_visited = models.IntegerField(default=0)
    schemes_applied = models.IntegerField(default=0)

class Prescription(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    file = models.FileField(upload_to='prescriptions/')

class HealthRecord(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    data = models.TextField()

class Appointment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.DateTimeField()
    status = models.CharField(max_length=50)

class Notification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    message = models.TextField()
    seen = models.BooleanField(default=False)

# serializers.py
from rest_framework import serializers
from .models import *
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

class UserProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = UserProfile
        fields = ['user', 'location']

class HealthJourneySerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthJourney
        fields = '__all__'

class PrescriptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Prescription
        fields = '__all__'

class HealthRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthRecord
        fields = '__all__'

class AppointmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Appointment
        fields = '__all__'

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'

# views.py
from rest_framework import viewsets, permissions
from .models import *
from .serializers import *

class UserProfileViewSet(viewsets.ModelViewSet):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

class HealthJourneyViewSet(viewsets.ModelViewSet):
    queryset = HealthJourney.objects.all()
    serializer_class = HealthJourneySerializer
    permission_classes = [permissions.IsAuthenticated]

class PrescriptionViewSet(viewsets.ModelViewSet):
    queryset = Prescription.objects.all()
    serializer_class = PrescriptionSerializer
    permission_classes = [permissions.IsAuthenticated]

class HealthRecordViewSet(viewsets.ModelViewSet):
    queryset = HealthRecord.objects.all()
    serializer_class = HealthRecordSerializer
    permission_classes = [permissions.IsAuthenticated]

class AppointmentViewSet(viewsets.ModelViewSet):
    queryset = Appointment.objects.all()
    serializer_class = AppointmentSerializer
    permission_classes = [permissions.IsAuthenticated]

class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

# urls.py
from rest_framework.routers import DefaultRouter
from django.urls import path, include
from .views import *

router = DefaultRouter()
router.register('profile', UserProfileViewSet)
router.register('journey', HealthJourneyViewSet)
router.register('prescriptions', PrescriptionViewSet)
router.register('records', HealthRecordViewSet)
router.register('appointments', AppointmentViewSet)
router.register('notifications', NotificationViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
]
