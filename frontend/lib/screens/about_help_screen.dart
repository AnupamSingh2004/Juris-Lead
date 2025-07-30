import 'package:flutter/material.dart';

class AboutHelpScreen extends StatefulWidget {
  const AboutHelpScreen({Key? key}) : super(key: key);

  @override
  State<AboutHelpScreen> createState() => _AboutHelpScreenState();
}

class _AboutHelpScreenState extends State<AboutHelpScreen> {
  String selectedTab = 'about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Help'),
        backgroundColor: const Color(0xFF2E7D8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tab Navigation
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('about', 'About'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton('help', 'Help'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton('faq', 'FAQ'),
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label) {
    final isSelected = selectedTab == tabId;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tabId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D8A) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 'about':
        return _buildAboutContent();
      case 'help':
        return _buildHelpContent();
      case 'faq':
        return _buildFAQContent();
      default:
        return _buildAboutContent();
    }
  }

  Widget _buildAboutContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Info
          _buildAppInfo(),
          const SizedBox(height: 24),
          
          // About AarogyaRekha
          _buildAboutSection(),
          const SizedBox(height: 24),
          
          // Features
          _buildFeaturesSection(),
          const SizedBox(height: 24),
          
          // Credits
          _buildCreditsSection(),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/logo/logo.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'AarogyaRekha',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 8),
          
          const Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          
          const Text(
            'Drawing the Digital Line Between Health and Disease',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About AarogyaRekha',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 12),
          
          const Text(
            'AarogyaRekha is an AI-powered preventive healthcare system that predicts and alerts communities about potential disease outbreaks like malaria, dengue, diarrhea, and malnutrition — even before symptoms occur.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          
          const Text(
            'Our Mission',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 8),
          
          const Text(
            'To prevent disease outbreaks by using satellite data, AI, and community engagement to create a proactive healthcare system that protects communities before diseases can spread.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.satellite,
        'title': 'Satellite Intelligence',
        'description': 'Uses satellite data to predict disease outbreaks',
      },
      {
        'icon': Icons.smart_toy,
        'title': 'AI Health Assistant',
        'description': 'Multilingual chatbot for health queries',
      },
      {
        'icon': Icons.map,
        'title': 'Risk Mapping',
        'description': 'Interactive risk maps with real-time updates',
      },
      {
        'icon': Icons.warning,
        'title': 'Early Alerts',
        'description': 'Proactive notifications before outbreaks',
      },
      {
        'icon': Icons.people,
        'title': 'Community Focus',
        'description': 'Designed for health workers and communities',
      },
      {
        'icon': Icons.analytics,
        'title': 'Data Analytics',
        'description': 'Comprehensive health trend analysis',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 16),
          
          ...features.map((feature) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D8A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: const Color(0xFF2E7D8A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['description'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildCreditsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Credits & Acknowledgments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 12),
          
          const Text(
            'Data Sources:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          const Text(
            '• Sentinel-2 Satellite Data\n• MODIS Climate Data\n• ISRO Bhuvan Geo-platform\n• WHO Health Guidelines\n• Ministry of Health and Family Welfare',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          
          const Text(
            'Technology Stack:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          const Text(
            '• Flutter for Mobile App\n• Django for Backend\n• TensorFlow for AI Models\n• Google Maps API\n• OpenWeatherMap API',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpSection('Getting Started', [
            'Welcome to AarogyaRekha! This app helps you stay informed about health risks in your area.',
            'Select your user type during setup for personalized features.',
            'Enable location services for accurate risk information.',
          ]),
          
          const SizedBox(height: 20),
          
          _buildHelpSection('Dashboard', [
            'View real-time health risk status for your location.',
            'Check weather conditions and health impacts.',
            'Access emergency contacts quickly.',
            'See recent health notifications and alerts.',
          ]),
          
          const SizedBox(height: 20),
          
          _buildHelpSection('Risk Map', [
            'Interactive map showing disease risk zones.',
            'Different colors indicate risk levels (Green: Safe, Yellow: Caution, Red: High Risk).',
            'Use filters to view specific disease risks.',
            'Tap on areas for detailed risk information.',
          ]),
          
          const SizedBox(height: 20),
          
          _buildHelpSection('Alerts & Notifications', [
            'Receive real-time health alerts for your area.',
            'View active health warnings and advisories.',
            'Access prevention guidelines and tips.',
            'Track alert history and updates.',
          ]),
          
          const SizedBox(height: 20),
          
          _buildHelpSection('AI Assistant', [
            'Ask health-related questions in multiple languages.',
            'Get symptom guidance and health tips.',
            'Access prevention recommendations.',
            'Available 24/7 for health queries.',
          ]),
          
          const SizedBox(height: 20),
          
          _buildContactSupport(),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 12),
          
          ...items.map((item) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFF2E7D8A))),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildContactSupport() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8A),
            ),
          ),
          const SizedBox(height: 12),
          
          _buildContactItem(Icons.email, 'Email', 'support@aarogyarekha.in'),
          _buildContactItem(Icons.phone, 'Phone', '+91-1800-XXX-XXXX'),
          _buildContactItem(Icons.language, 'Website', 'www.aarogyarekha.in'),
          _buildContactItem(Icons.schedule, 'Support Hours', '24/7 Emergency Support'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2E7D8A),
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQContent() {
    final faqs = [
      {
        'question': 'How does AarogyaRekha predict disease outbreaks?',
        'answer': 'AarogyaRekha uses satellite data, climate patterns, and AI models to analyze environmental conditions that contribute to disease spread. This includes monitoring water bodies, vegetation, temperature, and humidity patterns.',
      },
      {
        'question': 'Is my location data secure?',
        'answer': 'Yes, your location data is encrypted and used only for providing accurate health risk information. We follow strict privacy guidelines and do not share personal data with third parties.',
      },
      {
        'question': 'How accurate are the health predictions?',
        'answer': 'Our AI models are trained on historical data and validated against real outbreak patterns. While predictions are highly accurate, they should be used as guidance alongside official health advisories.',
      },
      {
        'question': 'Can I use the app offline?',
        'answer': 'Yes, essential features like cached risk information and basic health guidance are available offline. However, real-time updates require internet connectivity.',
      },
      {
        'question': 'How often is the data updated?',
        'answer': 'Risk maps and weather data are updated every 6-12 hours. Emergency alerts are sent immediately when risks are detected.',
      },
      {
        'question': 'What languages are supported?',
        'answer': 'AarogyaRekha supports Hindi, English, Bengali, Telugu, Tamil, Marathi, and other regional languages. Voice navigation is available for low-literacy users.',
      },
      {
        'question': 'How do I report a suspected outbreak?',
        'answer': 'Use the Emergency Report feature in the app or contact your local health worker. The app will guide you through the reporting process.',
      },
      {
        'question': 'Can tourists use this app?',
        'answer': 'Yes, tourists can select the Tourist user type to get travel-specific health risks, safe routes, and nearby healthcare facilities.',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: faqs.map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)).toList(),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
