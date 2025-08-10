import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/authentication_screen.dart';
import '../services/user_statistics_service.dart';

class ProfileScreenDynamic extends StatefulWidget {
  const ProfileScreenDynamic({super.key});

  @override
  State<ProfileScreenDynamic> createState() => _ProfileScreenDynamicState();
}

class _ProfileScreenDynamicState extends State<ProfileScreenDynamic>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;
  
  // User data
  bool _isLoggedIn = false;
  String _userName = 'Guest User';
  String _userEmail = '';
  String _userPhoto = '';
  String _userType = 'client';
  String _subscriptionType = 'free';
  bool _isPremium = false;
  int _casesAnalyzed = 12;
  int _documentsProcessed = 35;
  int _aiConsultations = 8;
  String _joinDate = 'January 2024';
  bool _isEditing = false;
  
  // User profile data
  final Map<String, dynamic> _userProfile = {
    'phone': '+91 98765 43210',
    'location': 'Mumbai, Maharashtra',
    'occupation': 'Software Engineer',
    'company': 'Tech Solutions Pvt Ltd',
    'bio': 'Passionate about technology and legal innovation. Looking for expert legal guidance for business matters.',
    'interests': ['Corporate Law', 'Intellectual Property', 'Technology Law'],
    'languages': ['English', 'Hindi', 'Marathi'],
  };

  // Controllers for editing
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _companyController = TextEditingController();
  final _bioController = TextEditingController();

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
    _initializeControllers();
  }

  @override
  void didUpdateWidget(ProfileScreenDynamic oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload user data when widget updates
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

  void _initializeControllers() {
    _nameController.text = _userName;
    _emailController.text = _userEmail;
    _phoneController.text = _userProfile['phone'] ?? '';
    _locationController.text = _userProfile['location'] ?? '';
    _occupationController.text = _userProfile['occupation'] ?? '';
    _companyController.text = _userProfile['company'] ?? '';
    _bioController.text = _userProfile['bio'] ?? '';
  }

  Future<void> _loadUserData() async {
    try {
      // Load actual user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
        _userName = prefs.getString('user_name') ?? 'Guest User';
        _userEmail = prefs.getString('user_email') ?? '';
        _userPhoto = prefs.getString('user_photo') ?? '';
        _userType = prefs.getString('user_type') ?? 'client';
        _subscriptionType = prefs.getString('subscription_type') ?? 'free';
        _isPremium = prefs.getBool('is_premium') ?? false;
        
        // Load statistics
        _casesAnalyzed = prefs.getInt('cases_analyzed') ?? 0;
        _documentsProcessed = prefs.getInt('documents_processed') ?? 0;
        _aiConsultations = prefs.getInt('ai_consultations') ?? 0;
        
        // Format join date
        final joinDateString = prefs.getString('join_date');
        if (joinDateString != null) {
          try {
            final joinDateTime = DateTime.parse(joinDateString);
            _joinDate = '${_getMonthName(joinDateTime.month)} ${joinDateTime.year}';
          } catch (e) {
            _joinDate = 'Recently';
          }
        } else {
          _joinDate = 'Recently';
        }
        
        // Load additional profile data from SharedPreferences if available
        _userProfile['phone'] = prefs.getString('user_phone') ?? '';
        _userProfile['location'] = prefs.getString('user_location') ?? '';
        _userProfile['occupation'] = prefs.getString('user_occupation') ?? '';
        _userProfile['company'] = prefs.getString('user_company') ?? '';
        _userProfile['bio'] = prefs.getString('user_bio') ?? '';
        
        // Update controller values
        _nameController.text = _userName;
        _emailController.text = _userEmail;
        _phoneController.text = _userProfile['phone'];
        _locationController.text = _userProfile['location'];
        _occupationController.text = _userProfile['occupation'];
        _companyController.text = _userProfile['company'];
        _bioController.text = _userProfile['bio'];
      });
      
      // Refresh statistics using the service
      _refreshStatistics();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _occupationController.dispose();
    _companyController.dispose();
    _bioController.dispose();
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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildAppBar(colorScheme),
          ],
          body: RefreshIndicator(
            onRefresh: () async {
              await _loadUserData();
              _initializeControllers();
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(colorScheme),
                _buildProfileTab(colorScheme),
                _buildSubscriptionTab(colorScheme),
                _buildSettingsTab(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: _userPhoto.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            _userPhoto,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: colorScheme.primary,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userEmail,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isPremium ? Colors.amber : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _subscriptionType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          Tab(icon: Icon(Icons.person), text: 'Profile'),
          Tab(icon: Icon(Icons.payment), text: 'Subscription'),
          Tab(icon: Icon(Icons.settings), text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Cases Analyzed',
                  _casesAnalyzed.toString(),
                  Icons.gavel,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Documents',
                  _documentsProcessed.toString(),
                  Icons.description,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'AI Consultations',
                  _aiConsultations.toString(),
                  Icons.smart_toy,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Member Since',
                  _joinDate,
                  Icons.calendar_today,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityList(),
          
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {'action': 'Analyzed criminal case', 'time': '2 hours ago', 'icon': Icons.gavel},
      {'action': 'Downloaded legal template', 'time': '1 day ago', 'icon': Icons.download},
      {'action': 'AI consultation session', 'time': '3 days ago', 'icon': Icons.smart_toy},
      {'action': 'Profile updated', 'time': '1 week ago', 'icon': Icons.person},
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: Icon(activity['icon'] as IconData),
            title: Text(activity['action'] as String),
            subtitle: Text(activity['time'] as String),
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Start Analysis',
                Icons.analytics,
                colorScheme.primary,
                () => _showComingSoon(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Find Lawyers',
                Icons.search,
                Colors.blue,
                () => Navigator.pushNamed(context, '/find-lawyers'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'AI Assistant',
                Icons.smart_toy,
                Colors.purple,
                () => _showComingSoon(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Templates',
                Icons.description,
                Colors.green,
                () => _showComingSoon(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                    if (!_isEditing) {
                      _saveProfile();
                    }
                  });
                },
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildProfileField('Full Name', _nameController, Icons.person),
          const SizedBox(height: 16),
          _buildProfileField('Email', _emailController, Icons.email),
          const SizedBox(height: 16),
          _buildProfileField('Phone', _phoneController, Icons.phone),
          const SizedBox(height: 16),
          _buildProfileField('Location', _locationController, Icons.location_on),
          const SizedBox(height: 16),
          _buildProfileField('Occupation', _occupationController, Icons.work),
          const SizedBox(height: 16),
          _buildProfileField('Company', _companyController, Icons.business),
          const SizedBox(height: 16),
          _buildProfileField('Bio', _bioController, Icons.info, maxLines: 3),
          
          const SizedBox(height: 24),
          
          Text(
            'Interests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _buildInterestChips(),
          
          const SizedBox(height: 24),
          
          Text(
            'Languages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _buildLanguageChips(),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: !_isEditing,
        fillColor: _isEditing ? null : Colors.grey[100],
      ),
    );
  }

  Widget _buildInterestChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: (_userProfile['interests'] as List<String>).map((interest) {
        return Chip(
          label: Text(interest),
          backgroundColor: Colors.blue[100],
          labelStyle: const TextStyle(color: Colors.blue),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: (_userProfile['languages'] as List<String>).map((language) {
        return Chip(
          label: Text(language),
          backgroundColor: Colors.green[100],
          labelStyle: const TextStyle(color: Colors.green),
        );
      }).toList(),
    );
  }

  Widget _buildSubscriptionTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Plan
          Text(
            'Current Plan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildCurrentPlanCard(),
          
          const SizedBox(height: 24),
          
          // Available Plans
          Text(
            'Available Plans',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._subscriptionPlans.map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPlanCard(plan),
          )),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    final currentPlan = _subscriptionPlans.firstWhere(
      (plan) => plan['name'].toString().toLowerCase() == _subscriptionType,
      orElse: () => _subscriptionPlans[0],
    );

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              currentPlan['color'].withOpacity(0.1),
              currentPlan['color'].withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.stars,
                  color: currentPlan['color'],
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPlan['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${currentPlan['price']}${currentPlan['period']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: currentPlan['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (currentPlan['popular'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'CURRENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Next billing: ${DateTime.now().add(const Duration(days: 30)).day}/${DateTime.now().add(const Duration(days: 30)).month}/${DateTime.now().add(const Duration(days: 30)).year}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isCurrentPlan = plan['name'].toString().toLowerCase() == _subscriptionType;
    
    return Card(
      elevation: isCurrentPlan ? 8 : 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: plan['popular'] ? Border.all(color: Colors.amber, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: plan['color'],
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (plan['popular'])
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '${plan['price']}${plan['period']}',
                        style: TextStyle(
                          fontSize: 20,
                          color: plan['color'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(plan['features'] as List<String>).map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: plan['color'],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(feature),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrentPlan ? null : () => _upgradePlan(plan['name']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrentPlan ? Colors.grey : plan['color'],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isCurrentPlan ? 'Current Plan' : 'Upgrade to ${plan['name']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingsItem(
            'Notifications',
            'Manage your notification preferences',
            Icons.notifications,
            () => _showComingSoon(),
          ),
          _buildSettingsItem(
            'Privacy & Security',
            'Control your privacy settings',
            Icons.security,
            () => _showComingSoon(),
          ),
          _buildSettingsItem(
            'Data & Storage',
            'Manage your data and storage',
            Icons.storage,
            () => _showComingSoon(),
          ),
          _buildSettingsItem(
            'Help & Support',
            'Get help and contact support',
            Icons.help,
            () => _showComingSoon(),
          ),
          _buildSettingsItem(
            'About',
            'App version and legal information',
            Icons.info,
            () => _showComingSoon(),
          ),
          
          const SizedBox(height: 24),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save main user data with correct keys
      await prefs.setString('user_name', _nameController.text);
      await prefs.setString('user_email', _emailController.text);
      
      // Save additional profile data
      await prefs.setString('user_phone', _phoneController.text);
      await prefs.setString('user_location', _locationController.text);
      await prefs.setString('user_occupation', _occupationController.text);
      await prefs.setString('user_company', _companyController.text);
      await prefs.setString('user_bio', _bioController.text);
      
      setState(() {
        _userName = _nameController.text;
        _userEmail = _emailController.text;
        _userProfile['phone'] = _phoneController.text;
        _userProfile['location'] = _locationController.text;
        _userProfile['occupation'] = _occupationController.text;
        _userProfile['company'] = _companyController.text;
        _userProfile['bio'] = _bioController.text;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _upgradePlan(String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to $planName'),
        content: Text('Are you sure you want to upgrade to the $planName plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPlanUpgrade(planName);
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _processPlanUpgrade(String planName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('subscription_type', planName.toLowerCase());
      
      setState(() {
        _subscriptionType = planName.toLowerCase();
        _isPremium = _subscriptionType != 'free';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully upgraded to $planName plan!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upgrade plan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to refresh statistics display using the service
  void _refreshStatistics() async {
    final stats = await UserStatisticsService.getCurrentStatistics();
    setState(() {
      _casesAnalyzed = stats['cases_analyzed'] ?? 0;
      _documentsProcessed = stats['documents_processed'] ?? 0;
      _aiConsultations = stats['ai_consultations'] ?? 0;
    });
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthenticationScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
