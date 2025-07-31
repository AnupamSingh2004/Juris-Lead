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
        backgroundColor: const Color(0xFF1565C0), // Legal blue
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
          color: isSelected ? const Color(0xFF1565C0) : Colors.grey[200], // Legal blue
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
            'Juris-Lead',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0), // Legal blue
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
            'Bridging the Gap Between Law and Justice',
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
            'About Juris-Lead',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0), // Legal blue
            ),
          ),
          const SizedBox(height: 12),
          
          const Text(
            'Juris-Lead is an AI-powered legal analysis platform that helps citizens understand Indian Penal Code (IPC) sections applicable to their legal situations. Our platform provides free legal case analysis for citizens and premium tools for legal professionals.',
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
              color: Color(0xFF1565C0), // Legal blue
            ),
          ),
          const SizedBox(height: 8),
          
          const Text(
            'To democratize access to legal knowledge by providing AI-powered IPC analysis that helps citizens understand their legal rights and empowers legal professionals with advanced tools for better client service.',
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
        'icon': Icons.gavel,
        'title': 'IPC Analysis',
        'description': 'AI-powered analysis of Indian Penal Code sections',
      },
      {
        'icon': Icons.smart_toy,
        'title': 'Legal AI Assistant',
        'description': 'Multilingual chatbot for legal queries and guidance',
      },
      {
        'icon': Icons.security,
        'title': 'Secure Analysis',
        'description': 'Anonymous and encrypted legal case processing',
      },
      {
        'icon': Icons.warning_amber,
        'title': 'Legal Guidance',
        'description': 'Preliminary legal advice and IPC section identification',
      },
      {
        'icon': Icons.people,
        'title': 'Multi-User Support',
        'description': 'Designed for citizens, lawyers, and legal professionals',
      },
      {
        'icon': Icons.analytics,
        'title': 'Case Analytics',
        'description': 'Comprehensive legal case trend analysis for professionals',
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
              color: Color(0xFF1565C0), // Legal blue
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
                      color: const Color(0xFF1565C0).withOpacity(0.1), // Legal blue
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: const Color(0xFF1565C0), // Legal blue
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
              color: Color(0xFF1565C0), // Legal blue
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
            '• Indian Penal Code (IPC) Database\n• Legal Precedents and Case Laws\n• Ministry of Law and Justice\n• Bar Council of India Guidelines\n• Supreme Court and High Court Judgments',
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
            '• Flutter for Mobile App\n• Django for Backend API\n• Ollama AI for Legal Analysis\n• PostgreSQL Database\n• Custom IPC-Helper AI Model',
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
            'Welcome to Juris-Lead! This app helps you understand legal implications of various situations and provides IPC analysis.',
            'Select your user type during setup for personalized features.',
            'Enable location services for accurate risk information.',
          ]),
          
          const SizedBox(height: 20),
          
          _buildHelpSection('Dashboard', [
            'View your legal analysis history and recent cases.',
            'Access quick IPC section lookup tools.',
            'Check your account status and subscription details.',
            'See recent legal notifications and updates.',
          ]),
          
          const SizedBox(height: 20),
          
          _buildHelpSection('Legal Analysis', [
            'Submit case descriptions for AI-powered IPC analysis.',
            'Get applicable section numbers with explanations.',
            'Understand why specific sections apply to your case.',
            'Save and review your analysis history.',
          ]),
          
          const SizedBox(height: 20),
          
          _buildHelpSection('AI Legal Assistant', [
            'Ask legal questions in multiple Indian languages.',
            'Get guidance on IPC sections and legal procedures.',
            'Access legal definitions and explanations.',
            'Available 24/7 for preliminary legal guidance.',
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
                  const Text('• ', style: TextStyle(color: Color(0xFF1565C0))), // Legal blue
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
              color: Color(0xFF1565C0), // Legal blue
            ),
          ),
          const SizedBox(height: 12),
          
          _buildContactItem(Icons.email, 'Email', 'support@juris-lead.in'),
          _buildContactItem(Icons.phone, 'Phone', '+91-1800-XXX-XXXX'),
          _buildContactItem(Icons.language, 'Website', 'www.juris-lead.in'),
          _buildContactItem(Icons.schedule, 'Support Hours', '24/7 Legal Guidance'),
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
            color: const Color(0xFF1565C0), // Legal blue
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
        'question': 'How does Juris-Lead provide legal analysis?',
        'answer': 'Juris-Lead uses AI-powered analysis trained on Indian Penal Code to identify applicable sections based on case descriptions. Our system provides section numbers, descriptions, and explanations of why they apply to your situation.',
      },
      {
        'question': 'Is my case information secure?',
        'answer': 'Yes, all case information is encrypted and processed securely. We follow strict privacy guidelines and do not share personal legal information with third parties. Anonymous analysis ensures your privacy.',
      },
      {
        'question': 'How accurate are the legal analyses?',
        'answer': 'Our AI models are trained on comprehensive IPC data and legal precedents. While highly accurate, our analysis should be used as guidance alongside consultation with qualified legal professionals.',
      },
      {
        'question': 'Can I use the app for serious legal matters?',
        'answer': 'Juris-Lead provides preliminary analysis and guidance. For serious legal matters, court cases, or complex situations, we strongly recommend consulting with a qualified lawyer or legal expert.',
      },
      {
        'question': 'What is the difference between free and premium features?',
        'answer': 'Citizens get free basic legal analysis and IPC section identification. Lawyers and legal professionals get access to premium features like detailed case analytics, precedent search, and advanced dashboard tools.',
      },
      {
        'question': 'What languages are supported?',
        'answer': 'Juris-Lead supports Hindi, English, and other major Indian languages. We are continuously expanding language support for better accessibility.',
      },
      {
        'question': 'How do I report incorrect analysis?',
        'answer': 'Use the feedback feature in the app to report any concerns about legal analysis. Our team reviews all feedback to improve the AI model accuracy.',
      },
      {
        'question': 'Can law students use this platform?',
        'answer': 'Yes, law students can access educational resources, case studies, and practice with IPC analysis. Special student features help with legal education and understanding.',
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
