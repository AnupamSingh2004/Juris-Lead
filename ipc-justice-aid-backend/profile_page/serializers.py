from rest_framework import serializers
from django.contrib.auth.models import User
from authentication.models import UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()
    email = serializers.SerializerMethodField()
    
    class Meta:
        model = UserProfile
        fields = [
            'name', 'email', 'phone', 'location', 'description',
            'specialization', 'experience', 'bar_council_id', 'education',
            'expertise', 'achievements', 'practice_areas', 'court_admissions',
            'occupation', 'company', 'interests', 'user_type'
        ]
    
    def get_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}".strip()
    
    def get_email(self, obj):
        return obj.user.email
    
    def to_representation(self, instance):
        data = super().to_representation(instance)
        
        # Parse JSON fields if they exist
        if data.get('expertise'):
            try:
                import json
                data['expertise'] = json.loads(data['expertise']) if isinstance(data['expertise'], str) else data['expertise']
            except:
                data['expertise'] = []
        
        if data.get('interests'):
            try:
                import json
                data['interests'] = json.loads(data['interests']) if isinstance(data['interests'], str) else data['interests']
            except:
                data['interests'] = []
                
        if data.get('achievements'):
            try:
                import json
                data['achievements'] = json.loads(data['achievements']) if isinstance(data['achievements'], str) else data['achievements']
            except:
                data['achievements'] = []
        
        if data.get('practice_areas'):
            try:
                import json
                data['practice_areas'] = json.loads(data['practice_areas']) if isinstance(data['practice_areas'], str) else data['practice_areas']
            except:
                data['practice_areas'] = []
                
        if data.get('court_admissions'):
            try:
                import json
                data['court_admissions'] = json.loads(data['court_admissions']) if isinstance(data['court_admissions'], str) else data['court_admissions']
            except:
                data['court_admissions'] = []
        
        return data
    
    def update(self, instance, validated_data):
        import json
        
        # Handle JSON fields
        if 'expertise' in validated_data:
            validated_data['expertise'] = json.dumps(validated_data['expertise'])
        if 'interests' in validated_data:
            validated_data['interests'] = json.dumps(validated_data['interests'])
        if 'achievements' in validated_data:
            validated_data['achievements'] = json.dumps(validated_data['achievements'])
        if 'practice_areas' in validated_data:
            validated_data['practice_areas'] = json.dumps(validated_data['practice_areas'])
        if 'court_admissions' in validated_data:
            validated_data['court_admissions'] = json.dumps(validated_data['court_admissions'])
            
        return super().update(instance, validated_data)
