import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/authentication_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/chatbot_screen.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;
  
  // User data
  bool _isLoggedIn = false;
  String _userName = 'Guest User';
  String _userEmail = '';
  String _userPhoto = '';
  String _userType = 'guest';
  String _subscriptionType = 'free';
  bool _isPremium = false;
  int _casesAnalyzed = 0;
  int _documentsProcessed = 0;
  int _aiConsultations = 0;
  String _joinDate = '';
  bool _isEditing = false;
  
  // User profile data
  final Map<String, dynamic> _userProfile = {
    'phone': '',
    'location': '',
    'occupation': '',
    'company': '',
    'bio': '',
    'interests': <String>[],
    'languages': <String>[],
  };

  // Subscription plans
  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      'name': 'Free',
      'price': '₹0',
      'period': '/month',
      'features': [
        '5 case analyses per month',
        'Basic legal templates',
        'Community support',
        'Standard response time',
      ],
      'popular': false,
      'color': Colors.grey,
    },
    {
      'name': 'Basic',
      'price': '₹499',
      'period': '/month',
      'features': [
        '50 case analyses per month',
        'All legal templates',
        'Email support',
        'Priority response',
        'AI legal assistant',
      ],
      'popular': false,
      'color': Colors.blue,
    },
    {
      'name': 'Premium',
      'price': '₹999',
      'period': '/month',
      'features': [
        'Unlimited case analyses',
        'Premium templates',
        'Phone & chat support',
        'Instant response',
        'Advanced AI insights',
        'Expert consultations',
      ],
      'popular': true,
      'color': Colors.purple,
    },
    {
      'name': 'Professional',
      'price': '₹1999',
      'period': '/month',
      'features': [
        'Everything in Premium',
        'White-label solutions',
        'API access',
        'Custom integrations',
        'Dedicated support',
        'Team collaboration',
      ],
      'popular': false,
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _tabController = TabController(length: 4, vsync: this);
    _animationController.forward();
  }
      curve: Curves.easeIn,
    ));
    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      // First try to load from API
      final user = await ApiService.getCurrentUser();
      if (user != null) {
        setState(() {
          _isLoggedIn = true;
          _userName = '${user.firstName} ${user.lastName}';
          _userEmail = user.email;
          _userType = user.userRole;
          _userPhoto = ''; // Can be added later
          // Load statistics from API if available
        });
      } else {
        // Fall back to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
          _userName = prefs.getString('user_name') ?? 'Guest User';
          _userEmail = prefs.getString('user_email') ?? '';
          _userPhoto = prefs.getString('user_photo') ?? '';
          _userType = prefs.getString('user_type') ?? 'guest';
          _subscriptionType = prefs.getString('subscription_type') ?? 'free';
          _isPremium = prefs.getBool('is_premium') ?? false;
          _casesAnalyzed = prefs.getInt('cases_analyzed') ?? 0;
          _documentsProcessed = prefs.getInt('documents_processed') ?? 0;
          _aiConsultations = prefs.getInt('ai_consultations') ?? 0;
          _joinDate = prefs.getString('join_date') ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Fall back to SharedPreferences on error
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
        _userName = prefs.getString('user_name') ?? 'Guest User';
        _userEmail = prefs.getString('user_email') ?? '';
        _userPhoto = prefs.getString('user_photo') ?? '';
        _userType = prefs.getString('user_type') ?? 'guest';
        _subscriptionType = prefs.getString('subscription_type') ?? 'free';
        _isPremium = prefs.getBool('is_premium') ?? false;
        _casesAnalyzed = prefs.getInt('cases_analyzed') ?? 0;
        _documentsProcessed = prefs.getInt('documents_processed') ?? 0;
        _aiConsultations = prefs.getInt('ai_consultations') ?? 0;
        _joinDate = prefs.getString('join_date') ?? '';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_userEmail.isNotEmpty)
                          Text(
                            _userEmail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _userType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),            // Profile Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // User Type & Subscription Card
                    _buildUserInfoCard(colorScheme),
                    const SizedBox(height: 16),
                    
                    // Statistics Card
                    _buildStatisticsCard(colorScheme),
                    const SizedBox(height: 16),
                    
                    // Quick Actions
                    _buildQuickActions(colorScheme),
                    const SizedBox(height: 16),
                    
                    // Profile Options
                    _buildProfileOptions(colorScheme),
                    
                    if (!_isLoggedIn) ...[
                      const SizedBox(height: 24),
                      _buildSignInPrompt(colorScheme),
                    ],
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          backgroundImage: _userPhoto.isNotEmpty
              ? NetworkImage(_userPhoto)
              : null,
          child: _userPhoto.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                )
              : null,
        ),
        if (_isPremium)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfoCard(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _userType == 'lawyer' ? Icons.balance : Icons.person,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('User Type', _getUserTypeDisplay(), Icons.person_outline),
            const SizedBox(height: 8),
            _buildInfoRow('Subscription', _getSubscriptionDisplay(), Icons.card_membership),
            if (_joinDate.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Member Since', _formatJoinDate(), Icons.calendar_today),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Cases Analyzed',
                    _casesAnalyzed.toString(),
                    Icons.gavel,
                    colorScheme,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Documents',
                    _documentsProcessed.toString(),
                    Icons.description,
                    colorScheme,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'AI Consultations',
                    _aiConsultations.toString(),
                    Icons.psychology,
                    colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'AI Chatbot',
                    Icons.chat,
                    colorScheme,
                    () => _navigateToChatbot(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Upgrade',
                    Icons.upgrade,
                    colorScheme,
                    () => _navigateToSubscription(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          _buildOptionTile(
            'Settings',
            'Manage your preferences',
            Icons.settings,
            () => _navigateToSettings(),
          ),
          const Divider(height: 1),
          _buildOptionTile(
            'Subscription & Billing',
            'Manage your subscription',
            Icons.payment,
            () => _navigateToSubscription(),
          ),
          const Divider(height: 1),
          _buildOptionTile(
            'Help & Support',
            'Get help and contact support',
            Icons.help,
            () => _showHelpDialog(),
          ),
          const Divider(height: 1),
          _buildOptionTile(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip,
            () => _showPrivacyPolicy(),
          ),
          if (_isLoggedIn) ...[
            const Divider(height: 1),
            _buildOptionTile(
              'Sign Out',
              'Sign out of your account',
              Icons.logout,
              () => _signOut(),
              textColor: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, ColorScheme colorScheme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, String subtitle, IconData icon, VoidCallback onTap, {Color? textColor}) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _getUserTypeDisplay() {
    switch (_userType) {
      case 'lawyer':
        return 'Legal Professional';
      case 'client':
        return 'Client';
      case 'guest':
        return 'Guest User';
      default:
        return 'User';
    }
  }

  String _getSubscriptionDisplay() {
    if (_isPremium) {
      return 'Premium';
    }
    switch (_subscriptionType) {
      case 'free':
        return 'Free';
      case 'basic':
        return 'Basic';
      case 'premium':
        return 'Premium';
      case 'professional':
        return 'Professional';
      default:
        return 'Free';
    }
  }

  String _formatJoinDate() {
    if (_joinDate.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(_joinDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _navigateToChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatbotScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    );
  }

  void _navigateToSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthenticationScreen()),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Need help with Juris-Lead?'),
              SizedBox(height: 16),
              Text('📧 Email: support@juris-lead.com'),
              Text('📞 Phone: +91 98765 43210'),
              Text('🕒 Hours: Mon-Fri 9 AM - 6 PM'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: const SingleChildScrollView(
            child: Text(
              'At Juris-Lead, we are committed to protecting your privacy. '
              'We collect and use your personal information only to provide '
              'and improve our legal analysis services. Your data is encrypted '
              'and stored securely. We do not share your information with third '
              'parties without your consent, except as required by law.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        setState(() {
          _isLoggedIn = false;
          _userName = 'Guest User';
          _userEmail = '';
          _userPhoto = '';
          _userType = 'guest';
          _subscriptionType = 'free';
          _isPremium = false;
          _casesAnalyzed = 0;
          _documentsProcessed = 0;
          _aiConsultations = 0;
          _joinDate = '';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully signed out'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // App Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
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
          
          const SizedBox(height: 32),
          
          Text(
            'Welcome to Juris-Lead',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Sign in to access your legal analysis history and personalized features',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Login Form
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoggedIn = true;
                      });
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Sign Up Option
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: theme.textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => _showSignUpDialog(),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    _userData['name']!.split(' ').map((n) => n[0]).join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userData['name']!,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _userData['userType']!,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _userData['email']!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Cases Analyzed',
                  value: _userData['casesAnalyzed'].toString(),
                  icon: Icons.analytics_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Member Since',
                  value: _userData['joinDate']!,
                  icon: Icons.calendar_today_outlined,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // My History Section
          _buildHistorySection(),
          
          const SizedBox(height: 24),
          
          // Menu Options
          _buildMenuOptions(),
          
          const SizedBox(height: 32),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isLoggedIn = false;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'My History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Recent Analysis Items
        ..._getRecentAnalyses().map((analysis) => _HistoryItem(
          title: analysis['title']!,
          date: analysis['date']!,
          status: analysis['status']!,
          onTap: () {},
        )),
      ],
    );
  }

  Widget _buildMenuOptions() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        _MenuOption(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: () {},
        ),
        _MenuOption(
          icon: Icons.security_outlined,
          title: 'Privacy & Security',
          onTap: () {},
        ),
        _MenuOption(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () {},
        ),
        _MenuOption(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {},
        ),
        _MenuOption(
          icon: Icons.info_outline,
          title: 'About',
          onTap: () {},
        ),
      ],
    );
  }

  List<Map<String, String>> _getRecentAnalyses() {
    return [
      {
        'title': 'Workplace Harassment Case Analysis',
        'date': '2 days ago',
        'status': 'Completed',
      },
      {
        'title': 'Property Dispute Consultation',
        'date': '1 week ago',
        'status': 'Completed',
      },
      {
        'title': 'Contract Review',
        'date': '2 weeks ago',
        'status': 'Completed',
      },
    ];
  }

  void _showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up'),
        content: const Text('Sign up functionality will be implemented with full authentication system.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final VoidCallback onTap;

  const _HistoryItem({
    required this.title,
    required this.date,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
