import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class ExploreLegalCasesScreen extends StatefulWidget {
  const ExploreLegalCasesScreen({super.key});

  @override
  State<ExploreLegalCasesScreen> createState() => _ExploreLegalCasesScreenState();
}

class _ExploreLegalCasesScreenState extends State<ExploreLegalCasesScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedCourt = 'All';
  String _selectedYear = 'All';
  
  List<Map<String, dynamic>> _cases = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<String> _categories = [
    'All',
    'Criminal Law',
    'Civil Law',
    'Constitutional Law',
    'Corporate Law',
    'Property Law',
    'Family Law',
    'Employment Law',
    'Tax Law',
    'Environmental Law',
    'Intellectual Property',
  ];

  final List<String> _courts = [
    'All',
    'Supreme Court of India',
    'High Court',
    'District Court',
    'Sessions Court',
    'Magistrate Court',
    'Tribunal',
  ];

  final List<String> _years = [
    'All',
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
    '2017',
    '2016',
    '2015',
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
    _loadFeaturedCases();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedCases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cases = await ApiService.getLegalCases();
      
      if (mounted) {
        setState(() {
          _cases = cases;
          _hasSearched = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If API fails, show sample data
      if (mounted) {
        setState(() {
          _cases = _getSampleCases();
          _hasSearched = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchCases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cases = await ApiService.getLegalCases();
      
      if (mounted) {
        setState(() {
          _cases = cases;
          _hasSearched = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If API fails, filter sample data
      if (mounted) {
        setState(() {
          _cases = _getFilteredSampleCases();
          _hasSearched = true;
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getSampleCases() {
    return [
      {
        'id': '1',
        'title': 'K.S. Puttaswamy v. Union of India',
        'citation': '(2017) 10 SCC 1',
        'court': 'Supreme Court of India',
        'year': 2017,
        'category': 'Constitutional Law',
        'judges': ['Justice J.S. Khehar', 'Justice J. Chelameswar', 'Justice S.A. Bobde'],
        'summary': 'Landmark judgment recognizing privacy as a fundamental right under Article 21 of the Constitution.',
        'keywords': ['Privacy', 'Fundamental Rights', 'Article 21', 'Constitutional Law'],
        'importance': 'High',
        'date': '2017-08-24',
        'parties': {
          'petitioner': 'K.S. Puttaswamy',
          'respondent': 'Union of India'
        },
        'key_points': [
          'Privacy is a fundamental right',
          'Aadhaar scheme constitutional with certain restrictions',
          'Right to privacy not absolute'
        ],
        'legal_principles': [
          'Fundamental right to privacy',
          'Proportionality test',
          'Constitutional interpretation'
        ]
      },
      {
        'id': '2',
        'title': 'Vishaka v. State of Rajasthan',
        'citation': '(1997) 6 SCC 241',
        'court': 'Supreme Court of India',
        'year': 1997,
        'category': 'Employment Law',
        'judges': ['Justice J.S. Verma', 'Justice Sujata V. Manohar', 'Justice B.N. Kirpal'],
        'summary': 'Guidelines for prevention of sexual harassment at workplace.',
        'keywords': ['Sexual Harassment', 'Workplace', 'Women Rights', 'Guidelines'],
        'importance': 'High',
        'date': '1997-08-13',
        'parties': {
          'petitioner': 'Vishaka',
          'respondent': 'State of Rajasthan'
        },
        'key_points': [
          'Workplace sexual harassment is violation of fundamental rights',
          'Mandatory guidelines for employers',
          'Internal complaints committee requirement'
        ],
        'legal_principles': [
          'Gender equality',
          'Safe working environment',
          'Judicial activism'
        ]
      },
      {
        'id': '3',
        'title': 'Maneka Gandhi v. Union of India',
        'citation': '(1978) 1 SCC 248',
        'court': 'Supreme Court of India',
        'year': 1978,
        'category': 'Constitutional Law',
        'judges': ['Justice P.N. Bhagwati', 'Justice V.R. Krishna Iyer', 'Justice N.L. Untwalia'],
        'summary': 'Expanded interpretation of Article 21 - Right to Life and Personal Liberty.',
        'keywords': ['Article 21', 'Personal Liberty', 'Due Process', 'Constitutional Interpretation'],
        'importance': 'High',
        'date': '1978-01-25',
        'parties': {
          'petitioner': 'Maneka Gandhi',
          'respondent': 'Union of India'
        },
        'key_points': [
          'Article 21 includes right to travel abroad',
          'Procedure must be fair, just and reasonable',
          'Expanded scope of personal liberty'
        ],
        'legal_principles': [
          'Due process of law',
          'Procedural fairness',
          'Constitutional interpretation'
        ]
      },
      {
        'id': '4',
        'title': 'Mohini Jain v. State of Karnataka',
        'citation': '(1992) 3 SCC 666',
        'court': 'Supreme Court of India',
        'year': 1992,
        'category': 'Constitutional Law',
        'judges': ['Justice Kuldip Singh', 'Justice R.M. Sahai'],
        'summary': 'Right to Education as fundamental right under Article 21.',
        'keywords': ['Right to Education', 'Article 21', 'Capitation Fee', 'Education'],
        'importance': 'High',
        'date': '1992-07-30',
        'parties': {
          'petitioner': 'Mohini Jain',
          'respondent': 'State of Karnataka'
        },
        'key_points': [
          'Education is fundamental right',
          'Capitation fee violates right to education',
          'State duty to provide education'
        ],
        'legal_principles': [
          'Right to education',
          'Equal access to education',
          'Constitutional obligation'
        ]
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredSampleCases() {
    final cases = _getSampleCases();
    return cases.where((caseData) {
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final title = caseData['title']?.toString().toLowerCase() ?? '';
        final summary = caseData['summary']?.toString().toLowerCase() ?? '';
        final keywords = (caseData['keywords'] as List? ?? []).join(' ').toLowerCase();
        
        if (!title.contains(query) && !summary.contains(query) && !keywords.contains(query)) {
          return false;
        }
      }
      
      if (_selectedCategory != 'All' && caseData['category'] != _selectedCategory) {
        return false;
      }
      
      if (_selectedCourt != 'All' && caseData['court'] != _selectedCourt) {
        return false;
      }
      
      if (_selectedYear != 'All' && caseData['year'].toString() != _selectedYear) {
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
        title: const Text('Explore Legal Cases'),
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
                  title: const Text('Explore Legal Cases'),
                  content: const Text(
                    'Search and explore important legal cases:\n\n'
                    '• Search by case name or keywords\n'
                    '• Filter by legal category\n'
                    '• Filter by court level\n'
                    '• Filter by year of judgment\n\n'
                    'View detailed case information including judgments, key points, and legal principles.',
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
            // Search and Filters
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search cases',
                      hintText: 'Enter case name or keywords',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: Icon(Icons.filter_list),
                    ),
                    onSubmitted: (_) => _searchCases(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filter Row 1
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _categories.map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category, style: const TextStyle(fontSize: 14)),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value ?? 'All';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCourt,
                          decoration: const InputDecoration(
                            labelText: 'Court',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _courts.map((court) => DropdownMenuItem(
                            value: court,
                            child: Text(
                              court,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCourt = value ?? 'All';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Filter Row 2
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedYear,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _years.map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year, style: const TextStyle(fontSize: 14)),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value ?? 'All';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _searchCases,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.search),
                            label: Text(_isLoading ? 'Searching...' : 'Search'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _cases.isEmpty
                      ? _buildEmptyState()
                      : _buildCasesList(),
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
            _hasSearched ? 'No cases found' : 'No cases available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasSearched 
                ? 'Try adjusting your search criteria'
                : 'Use the search filters to find cases',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCasesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _cases.length,
      itemBuilder: (context, index) {
        final caseData = _cases[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _showCaseDetail(caseData),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              caseData['title']?.toString() ?? 'Unknown Case',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              caseData['citation']?.toString() ?? '',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getImportanceColor(caseData['importance']?.toString()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          caseData['importance']?.toString() ?? 'Medium',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Summary
                  Text(
                    caseData['summary']?.toString() ?? 'No summary available',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Keywords
                  if (caseData['keywords'] != null) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (caseData['keywords'] as List).take(3).map((keyword) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          keyword.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Footer
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          caseData['court']?.toString() ?? 'Unknown Court',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        caseData['year']?.toString() ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          caseData['category']?.toString() ?? 'General',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
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

  Color _getImportanceColor(String? importance) {
    switch (importance?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showCaseDetail(Map<String, dynamic> caseData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.7,
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
              
              // Case Details
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  caseData['title']?.toString() ?? 'Unknown Case',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  caseData['citation']?.toString() ?? '',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getImportanceColor(caseData['importance']?.toString()),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  caseData['importance']?.toString() ?? 'Medium',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _copyCitation(caseData['citation']?.toString()),
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy citation',
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Basic Info Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildInfoCard('Court', caseData['court']?.toString() ?? 'Unknown', Icons.account_balance),
                          _buildInfoCard('Year', caseData['year']?.toString() ?? 'Unknown', Icons.calendar_today),
                          _buildInfoCard('Category', caseData['category']?.toString() ?? 'General', Icons.category),
                          _buildInfoCard('Date', caseData['date']?.toString() ?? 'Unknown', Icons.event),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Parties
                      if (caseData['parties'] != null) ...[
                        _buildSectionTitle('Parties'),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16),
                                    const SizedBox(width: 8),
                                    const Text('Petitioner: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(caseData['parties']['petitioner']?.toString() ?? 'Unknown')),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 16),
                                    const SizedBox(width: 8),
                                    const Text('Respondent: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(caseData['parties']['respondent']?.toString() ?? 'Unknown')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Summary
                      _buildSectionTitle('Summary'),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            caseData['summary']?.toString() ?? 'No summary available',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Judges
                      if (caseData['judges'] != null) ...[
                        _buildSectionTitle('Bench'),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (caseData['judges'] as List).map((judge) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(judge.toString())),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Key Points
                      if (caseData['key_points'] != null) ...[
                        _buildSectionTitle('Key Points'),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (caseData['key_points'] as List).map((point) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(point.toString())),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Legal Principles
                      if (caseData['legal_principles'] != null) ...[
                        _buildSectionTitle('Legal Principles'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (caseData['legal_principles'] as List).map((principle) => Chip(
                            label: Text(principle.toString()),
                            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                          )).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Keywords
                      if (caseData['keywords'] != null) ...[
                        _buildSectionTitle('Keywords'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (caseData['keywords'] as List).map((keyword) => Chip(
                            label: Text(keyword.toString()),
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          )).toList(),
                        ),
                      ],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _copyCitation(String? citation) {
    if (citation != null && citation.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: citation));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Citation copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
