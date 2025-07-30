import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/auth_wrapper.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'notifications_screen.dart';
import 'privacy_security_screen.dart';
import 'settings_screen.dart';
import 'about_help_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userType;
  
  const ProfileScreen({super.key, required this.userType});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String? errorMessage;
  bool isLoadingLocation = false;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _getCurrentLocationAutomatically();
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await ApiService.getUserProfile();
      if (result['success']) {
        setState(() {
          userProfile = result['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load profile data';
        isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await ApiService.logout();
      if (mounted) {
        Navigator.of(context).pop();
        if (result['success']) {
          // Navigate to login screen (AuthWrapper will handle the redirect)
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Logout failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed')),
        );
      }
    }
  }

  Future<void> _getCurrentLocationAutomatically() async {
    try {
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          currentPosition = position;
        });
        
        // Update the user profile with location silently
        String locationString = LocationService.getFormattedLocation(position);
        // Here you could update the backend with the new location
        print('Location updated automatically: $locationString');
      }
    } catch (e) {
      print('Error getting location automatically: $e');
    }
  }

  Future<void> _makeEmergencyCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '108');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to make phone call'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error making phone call'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(errorMessage!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      _loadUserProfile();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 120 + MediaQuery.of(context).viewInsets.bottom, // Space for navbar
        ),
        child: Column(
          children: [
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 28, 
                  backgroundColor: Colors.blue[100],
                  child: userProfile?['profile_image'] != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          userProfile!['profile_image'],
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.person, size: 30),
                        ),
                      )
                    : const Icon(Icons.person, size: 30)
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${userProfile?['first_name'] ?? 'User'} ${userProfile?['last_name'] ?? ''}".trim(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userProfile?['email'] ?? 'email@example.com',
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (currentPosition != null)
                        Text("📍 ${LocationService.getFormattedLocation(currentPosition!)}")
                      else if (userProfile?['location'] != null)
                        Text("📍 ${userProfile!['location']}")
                      else if (userProfile?['city'] != null && userProfile?['country'] != null)
                        Text("📍 ${userProfile!['city']}, ${userProfile!['country']}")
                      else
                        Row(
                          children: [
                            if (isLoadingLocation)
                              const Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text("Getting location..."),
                                ],
                              )
                            else
                              const Text("📍 Location not available"),
                          ],
                        )
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit), 
                  onPressed: () {
                    // TODO: Navigate to edit profile screen when available
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profile feature coming soon')),
                    );
                  }
                )
              ],
            ),
            const SizedBox(height: 24),

            // Account Section
            
        
            sectionTile(
              Icons.notifications_outlined, 
              "Notifications",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            sectionTile(
              Icons.lock_outline, 
              "Privacy & Security",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacySecurityScreen(),
                  ),
                );
              },
            ),
            sectionTile(
              Icons.support_agent, 
              "Help & Support",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutHelpScreen(),
                  ),
                );
              },
            ),
            sectionTile(
              Icons.settings, 
              "Settings",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(userType: widget.userType),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Health Insight Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2E7D8A).withAlpha(26),
                    const Color(0xFF2E7D8A).withAlpha(13),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2E7D8A).withAlpha(51),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D8A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "💡 AarogyaRekha Insight",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D8A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Check your risk map daily to stay informed about health conditions in your area. Early awareness helps prevent disease outbreaks!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Emergency
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(child: Text("🚨 Emergency Helpline\n108 (National Ambulance)")),
                  ElevatedButton(
                    onPressed: _makeEmergencyCall,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Call Now"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _handleSignOut,
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              value, 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label, 
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
