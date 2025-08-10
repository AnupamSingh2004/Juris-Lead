import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FindLawyersScreen extends StatefulWidget {
  const FindLawyersScreen({super.key});

  @override
  State<FindLawyersScreen> createState() => _FindLawyersScreenState();
}

class _FindLawyersScreenState extends State<FindLawyersScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _locationController = TextEditingController();
  String _selectedSpecialization = 'All';
  double _selectedRating = 0.0;
  
  List<Map<String, dynamic>> _lawyers = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<String> _specializations = [
    'All',
    'Criminal Law',
    'Corporate Law',
    'Family Law',
    'Property Law',
    'Employment Law',
    'Tax Law',
    'Civil Law',
    'Constitutional Law',
    'Immigration Law',
    'Intellectual Property',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    _fadeController.forward();
    _loadFeaturedLawyers();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedLawyers() async {
    setState(() {
      _isLoading = true;
    });

    // Use hardcoded data instead of API call
    if (mounted) {
      setState(() {
        _lawyers = _getSampleLawyers();
        _hasSearched = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _searchLawyers() async {
    setState(() {
      _isLoading = true;
    });

    // Use hardcoded filtered data instead of API call
    if (mounted) {
      setState(() {
        _lawyers = _getFilteredSampleLawyers();
        _hasSearched = true;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getSampleLawyers() {
    return [
      {
        'id': '1',
        'name': 'Adv. Priya Sharma',
        'specialization': 'Criminal Law',
        'experience': 15,
        'rating': 4.9,
        'reviews': 127,
        'location': 'Mumbai, Maharashtra',
        'phone': '+91 98765 43210',
        'email': 'priya.sharma@example.com',
        'about': 'Specialized in complex criminal cases with over 15 years of experience in high-profile matters.',
        'cases_handled': 500,
        'languages': ['English', 'Hindi', 'Marathi'],
        'consultation_fee': 3000,
        'expertise': ['White Collar Crime', 'Criminal Defense', 'Bail Applications'],
        'verified': true,
        'responseTime': 'Within 2 hours',
        'successRate': 94,
      },
      {
        'id': '2',
        'name': 'Adv. Rajesh Kumar',
        'specialization': 'Corporate Law',
        'experience': 12,
        'rating': 4.7,
        'reviews': 89,
        'location': 'Delhi, NCR',
        'phone': '+91 98765 43211',
        'email': 'rajesh.kumar@example.com',
        'about': 'Expert in corporate transactions and regulatory compliance for businesses of all sizes.',
        'cases_handled': 350,
        'languages': ['English', 'Hindi'],
        'consultation_fee': 2500,
        'expertise': ['Mergers & Acquisitions', 'Corporate Compliance', 'Contract Law'],
        'verified': true,
        'responseTime': 'Within 4 hours',
        'successRate': 91,
      },
      {
        'id': '3',
        'name': 'Adv. Meera Patel',
        'specialization': 'Family Law',
        'experience': 10,
        'rating': 4.8,
        'reviews': 156,
        'location': 'Bangalore, Karnataka',
        'phone': '+91 98765 43212',
        'email': 'meera.patel@example.com',
        'about': 'Compassionate approach to family law matters with focus on amicable resolutions.',
        'cases_handled': 280,
        'languages': ['English', 'Hindi', 'Kannada'],
        'consultation_fee': 1800,
        'expertise': ['Divorce Proceedings', 'Child Custody', 'Property Settlement'],
        'verified': true,
        'responseTime': 'Within 6 hours',
        'successRate': 88,
      },
      {
        'id': '4',
        'name': 'Adv. Arjun Singh',
        'specialization': 'Property Law',
        'experience': 18,
        'rating': 4.6,
        'reviews': 203,
        'location': 'Chennai, Tamil Nadu',
        'phone': '+91 98765 43213',
        'email': 'arjun.singh@example.com',
        'about': 'Extensive experience in property law with successful track record in complex real estate matters.',
        'cases_handled': 750,
        'languages': ['English', 'Hindi', 'Tamil'],
        'consultation_fee': 2800,
        'expertise': ['Real Estate Transactions', 'Land Acquisition', 'Property Disputes'],
        'verified': true,
        'responseTime': 'Within 3 hours',
        'successRate': 92,
      },
      {
        'id': '5',
        'name': 'Adv. Kavya Nair',
        'specialization': 'Employment Law',
        'experience': 8,
        'rating': 4.5,
        'reviews': 74,
        'location': 'Kochi, Kerala',
        'phone': '+91 98765 43214',
        'email': 'kavya.nair@example.com',
        'about': 'Specializes in employment disputes, workplace harassment, and labor law compliance.',
        'cases_handled': 180,
        'languages': ['English', 'Hindi', 'Malayalam'],
        'consultation_fee': 1500,
        'expertise': ['Workplace Harassment', 'Employment Contracts', 'Labor Disputes'],
        'verified': true,
        'responseTime': 'Within 8 hours',
        'successRate': 85,
      },
      {
        'id': '6',
        'name': 'Adv. Rohit Agarwal',
        'specialization': 'Tax Law',
        'experience': 14,
        'rating': 4.7,
        'reviews': 112,
        'location': 'Pune, Maharashtra',
        'phone': '+91 98765 43215',
        'email': 'rohit.agarwal@example.com',
        'about': 'Expert in direct and indirect tax matters, GST compliance, and tax litigation.',
        'cases_handled': 420,
        'languages': ['English', 'Hindi', 'Marathi'],
        'consultation_fee': 2200,
        'expertise': ['GST Compliance', 'Income Tax', 'Tax Litigation'],
        'verified': true,
        'responseTime': 'Within 5 hours',
        'successRate': 89,
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredSampleLawyers() {
    final lawyers = _getSampleLawyers();
    return lawyers.where((lawyer) {
      if (_selectedSpecialization != 'All' && 
          lawyer['specialization'] != _selectedSpecialization) {
        return false;
      }
      if (_locationController.text.isNotEmpty && 
          !lawyer['location'].toString().toLowerCase().contains(_locationController.text.toLowerCase())) {
        return false;
      }
      if (_selectedRating > 0 && lawyer['rating'] < _selectedRating) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Lawyers'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Find Lawyers'),
                  content: const Text(
                    'Search for qualified lawyers based on:\n\n'
                    '• Legal specialization\n'
                    '• Location/City\n'
                    '• Minimum rating\n'
                    '• Experience level\n\n'
                    'Contact lawyers directly for consultations and legal advice.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Filters
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Location and Specialization
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            hintText: 'Enter city name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSpecialization,
                          decoration: const InputDecoration(
                            labelText: 'Specialization',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.gavel),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                          isExpanded: true,
                          items: _specializations.map((spec) => DropdownMenuItem(
                            value: spec,
                            child: Text(
                              spec,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSpecialization = value ?? 'All';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rating Filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Minimum Rating: ${_selectedRating > 0 ? _selectedRating.toStringAsFixed(1) : 'Any'}',
                              style: theme.textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _selectedRating,
                        min: 0.0,
                        max: 5.0,
                        divisions: 10,
                        onChanged: (value) {
                          setState(() {
                            _selectedRating = value;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _searchLawyers,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isLoading ? 'Searching...' : 'Search Lawyers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _lawyers.isEmpty
                      ? _buildEmptyState()
                      : _buildLawyersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _hasSearched ? 'No lawyers found' : 'No lawyers available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasSearched 
                ? 'Try adjusting your search criteria'
                : 'Use the search filters to find lawyers',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawyersList() {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _lawyers.length,
      itemBuilder: (context, index) {
        final lawyer = _lawyers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _showLawyerDetail(lawyer),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          lawyer['name']?.toString().split(' ').map((n) => n[0]).take(2).join('') ?? 'L',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lawyer['name']?.toString() ?? 'Unknown',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              lawyer['specialization']?.toString() ?? 'General Practice',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${lawyer['rating']?.toString() ?? '0.0'} (${lawyer['reviews']?.toString() ?? '0'} reviews) • ${lawyer['experience']?.toString() ?? '0'} years',
                                    style: theme.textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (lawyer['verified'] == true) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${lawyer['consultation_fee']?.toString() ?? '0'}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Consultation',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    lawyer['about']?.toString() ?? 'No description available',
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Expertise tags
                  if (lawyer['expertise'] != null && lawyer['expertise'] is List) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (lawyer['expertise'] as List)
                          .take(3)
                          .map<Widget>((expertise) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  expertise.toString(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontSize: 10,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lawyer['location']?.toString() ?? 'Unknown',
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.work,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${lawyer['cases_handled']?.toString() ?? '0'} cases',
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lawyer['responseTime'] != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            lawyer['responseTime'].toString(),
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (lawyer['successRate'] != null)
                        Flexible(
                          child: Text(
                            '${lawyer['successRate']}% Success Rate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      TextButton(
                        onPressed: () => _contactLawyer(lawyer),
                        child: const Text('Contact'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLawyerDetail(Map<String, dynamic> lawyer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Lawyer Profile
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              lawyer['name']?.toString().split(' ').map((n) => n[0]).take(2).join('') ?? 'L',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lawyer['name']?.toString() ?? 'Unknown',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  lawyer['specialization']?.toString() ?? 'General Practice',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    ...List.generate(5, (index) => Icon(
                                      Icons.star,
                                      size: 16,
                                      color: index < (lawyer['rating']?.toDouble() ?? 0).floor()
                                          ? Colors.amber
                                          : Colors.grey.shade300,
                                    )),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${lawyer['rating']?.toString() ?? '0.0'} (${lawyer['cases_handled']?.toString() ?? '0'} cases)',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // About
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lawyer['about']?.toString() ?? 'No description available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Details Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildDetailCard('Experience', '${lawyer['experience']?.toString() ?? '0'} years', Icons.work),
                          _buildDetailCard('Location', lawyer['location']?.toString() ?? 'Unknown', Icons.location_on),
                          _buildDetailCard('Cases', lawyer['cases_handled']?.toString() ?? '0', Icons.gavel),
                          _buildDetailCard('Fee', '₹${lawyer['consultation_fee']?.toString() ?? '0'}', Icons.payment),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Languages
                      if (lawyer['languages'] != null) ...[
                        Text(
                          'Languages',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: (lawyer['languages'] as List).map((lang) => Chip(
                            label: Text(lang.toString()),
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          )).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Contact Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _callLawyer(lawyer['phone']?.toString()),
                              icon: const Icon(Icons.phone),
                              label: const Text('Call'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _emailLawyer(lawyer['email']?.toString()),
                              icon: const Icon(Icons.email),
                              label: const Text('Email'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactLawyer(Map<String, dynamic> lawyer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact ${lawyer['name']}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call'),
              subtitle: Text(lawyer['phone']?.toString() ?? 'No phone number'),
              onTap: () {
                Navigator.pop(context);
                _callLawyer(lawyer['phone']?.toString());
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email'),
              subtitle: Text(lawyer['email']?.toString() ?? 'No email address'),
              onTap: () {
                Navigator.pop(context);
                _emailLawyer(lawyer['email']?.toString());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callLawyer(String? phone) async {
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone dialer'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _emailLawyer(String? email) async {
    if (email != null && email.isNotEmpty) {
      final uri = Uri.parse('mailto:$email?subject=Legal Consultation Inquiry');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch email client'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
