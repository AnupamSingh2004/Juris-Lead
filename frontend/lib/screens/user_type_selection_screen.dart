import 'package:flutter/material.dart';
import '../widgets/main_navigation.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1565C0), // Legal blue
              Color(0xFF0D47A1), // Darker blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo/logo.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // App Title
                const Text(
                  'Juris-Lead',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                const Text(
                  'Your Legal Analysis Platform',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // User type selection
                const Text(
                  'Select Your User Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Expanded(
                  child: Column(
                    children: [
                      _buildUserTypeButton(
                        context,
                        'Lawyer/Legal Professional',
                        'Access premium legal tools & dashboard',
                        Icons.gavel,
                        'Lawyer',
                      ),
                      const SizedBox(height: 16),
                      _buildUserTypeButton(
                        context,
                        'Citizen/Individual',
                        'Free legal analysis & consultation',
                        Icons.person,
                        'Citizen',
                      ),
                      const SizedBox(height: 16),
                      _buildUserTypeButton(
                        context,
                        'Law Student',
                        'Educational resources & case studies',
                        Icons.school,
                        'Student',
                      ),
                      const SizedBox(height: 16),
                      _buildUserTypeButton(
                        context,
                        'Legal Aid Organization',
                        'Non-profit legal assistance',
                        Icons.volunteer_activism,
                        'NGO',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Footer
                const Text(
                  'Bridging the Gap Between Law and Justice',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String userType,
  ) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainNavigation(userType: userType),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1565C0), // Legal blue
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1), // Legal blue with opacity
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1565C0), // Legal blue
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
