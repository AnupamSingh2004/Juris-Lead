from rest_framework import permissions


class IsLawyerUser(permissions.BasePermission):
    """
    Custom permission to only allow lawyers to access certain views.
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.user_role == 'lawyer'
        )


class IsClientUser(permissions.BasePermission):
    """
    Custom permission to only allow clients to access certain views.
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.user_role == 'client'
        )


class IsLawyerOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow lawyers to modify objects.
    Read permissions are allowed to any authenticated user.
    """
    
    def has_permission(self, request, view):
        # Read permissions for any authenticated user
        if request.method in permissions.SAFE_METHODS:
            return request.user and request.user.is_authenticated
        
        # Write permissions only for lawyers
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.user_role == 'lawyer'
        )


class IsOwnerOrLawyer(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object or lawyers to access it.
    """
    
    def has_object_permission(self, request, view, obj):
        # Check if the user is the owner of the object
        if hasattr(obj, 'user') and obj.user == request.user:
            return True
        
        # Check if the user is a lawyer
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.user_role == 'lawyer'
        )
