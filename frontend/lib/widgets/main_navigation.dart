import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/risk_map_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/chatbot_screen.dart';
import '../screens/reports_analytics_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_help_screen.dart';
import '../services/api_service.dart';
import '../widgets/auth_wrapper.dart';

class MainNavigation extends StatefulWidget {
  final String userType;
  
  const MainNavigation({Key? key, required this.userType}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(
        userType: widget.userType,
        onNavigateToRiskMap: () => _onItemTapped(1),
        onNavigateToAlerts: () => _onItemTapped(2),
      ),
      RiskMapScreen(userType: widget.userType),
      AlertsScreen(userType: widget.userType),
      ChatbotScreen(userType: widget.userType),
      ReportsAnalyticsScreen(userType: widget.userType),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? null : AppBar(
        backgroundColor: const Color(0xFF2E7D8A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildSideMenu(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2E7D8A),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Risk Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildSettingsMenuItems(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2E7D8A),
            Color(0xFF1A5A6B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/logo/logo.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          const Text(
            'AarogyaRekha',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          Text(
            _getUserTypeDisplayName(widget.userType),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenuItems() {
    return Column(
      children: [
        _buildMenuItem(Icons.person, 'Profile', () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ProfileScreen(userType: widget.userType),
          ));
        }),
        _buildMenuItem(Icons.settings, 'Settings', () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => SettingsScreen(userType: widget.userType),
          ));
        }),
        _buildMenuItem(Icons.help, 'Help & Support', () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const AboutHelpScreen(),
          ));
        }),
        _buildMenuItem(Icons.logout, 'Logout', () {
          _showLogoutDialog();
        }),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF2E7D8A),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  String _getUserTypeDisplayName(String userType) {
    switch (userType) {
      case 'ASHA/ANM':
        return 'ASHA/ANM Worker';
      case 'PHC':
        return 'PHC/District Official';
      case 'Rural':
        return 'Rural Household';
      case 'Tourist':
        return 'Tourist';
      default:
        return 'User';
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              try {
                final result = await ApiService.logout();
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
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
                  Navigator.of(context).pop(); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout failed')),
                  );
                }
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
