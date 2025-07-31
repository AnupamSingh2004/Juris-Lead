import 'package:flutter/material.dart';

class FindLawyerScreen extends StatefulWidget {
  const FindLawyerScreen({super.key});

  @override
  State<FindLawyerScreen> createState() => _FindLawyerScreenState();
}

class _FindLawyerScreenState extends State<FindLawyerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedFilters = [];
  final List<LawyerProfile> _lawyers = _generateSampleLawyers();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        selectedFilters: _selectedFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _selectedFilters = filters;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Lawyer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search lawyers by name, specialization...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                // Active Filters
                if (_selectedFilters.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedFilters.map((filter) {
                        return Chip(
                          label: Text(filter),
                          onDeleted: () {
                            setState(() {
                              _selectedFilters.remove(filter);
                            });
                          },
                          deleteIcon: const Icon(Icons.close, size: 16),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Results Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  '${_lawyers.length} lawyers found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: 'Rating',
                  items: const [
                    DropdownMenuItem(value: 'Rating', child: Text('Sort by Rating')),
                    DropdownMenuItem(value: 'Experience', child: Text('Sort by Experience')),
                    DropdownMenuItem(value: 'Fees', child: Text('Sort by Fees')),
                  ],
                  onChanged: (value) {},
                  underline: const SizedBox(),
                ),
              ],
            ),
          ),
          
          // Lawyers List
          Expanded(
            child: FadeTransition(
              opacity: _animationController,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _lawyers.length,
                itemBuilder: (context, index) {
                  return _LawyerCard(
                    lawyer: _lawyers[index],
                    onTap: () => _navigateToLawyerProfile(_lawyers[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLawyerProfile(LawyerProfile lawyer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LawyerDetailScreen(lawyer: lawyer),
      ),
    );
  }

  static List<LawyerProfile> _generateSampleLawyers() {
    return [
      LawyerProfile(
        id: '1',
        name: 'Adv. Priya Sharma',
        specialization: 'Criminal Law',
        experience: 12,
        rating: 4.8,
        reviewCount: 124,
        location: 'Delhi High Court',
        fees: '₹2,500/hr',
        imageUrl: 'assets/images/lawyer1.jpg',
        bio: 'Experienced criminal lawyer with expertise in cyber crime and financial fraud cases.',
        achievements: ['Delhi Bar Association Member', 'Won 85% of cases'],
      ),
      LawyerProfile(
        id: '2',
        name: 'Adv. Rajesh Kumar',
        specialization: 'Civil Law',
        experience: 8,
        rating: 4.6,
        reviewCount: 98,
        location: 'Mumbai',
        fees: '₹2,000/hr',
        imageUrl: 'assets/images/lawyer2.jpg',
        bio: 'Specialist in property disputes and contract law with a strong track record.',
        achievements: ['Maharashtra Bar Council Member', 'Property Law Expert'],
      ),
      LawyerProfile(
        id: '3',
        name: 'Adv. Meera Patel',
        specialization: 'Family Law',
        experience: 15,
        rating: 4.9,
        reviewCount: 156,
        location: 'Ahmedabad',
        fees: '₹1,800/hr',
        imageUrl: 'assets/images/lawyer3.jpg',
        bio: 'Family law expert specializing in divorce, custody, and domestic violence cases.',
        achievements: ['Gujarat High Court Practice', 'Women Rights Advocate'],
      ),
    ];
  }
}

class _LawyerCard extends StatelessWidget {
  final LawyerProfile lawyer;
  final VoidCallback onTap;

  const _LawyerCard({
    required this.lawyer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Lawyer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lawyer.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            lawyer.specialization,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lawyer.rating}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' (${lawyer.reviewCount} reviews)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Fees
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        lawyer.fees,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${lawyer.experience} years exp.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Bio
              Text(
                lawyer.bio,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text('Message'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_today_outlined, size: 16),
                      label: const Text('Book'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final List<String> selectedFilters;
  final Function(List<String>) onFiltersChanged;

  const _FilterBottomSheet({
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late List<String> _tempFilters;

  final Map<String, List<String>> _filterCategories = {
    'Specialization': [
      'Criminal Law',
      'Civil Law',
      'Family Law',
      'Corporate Law',
      'Tax Law',
      'Immigration Law',
    ],
    'Location': [
      'Delhi',
      'Mumbai',
      'Bangalore',
      'Chennai',
      'Kolkata',
      'Hyderabad',
    ],
    'Experience': [
      '0-5 years',
      '5-10 years',
      '10-15 years',
      '15+ years',
    ],
    'Fees Range': [
      'Under ₹1,000',
      '₹1,000 - ₹2,000',
      '₹2,000 - ₹5,000',
      'Above ₹5,000',
    ],
  };

  @override
  void initState() {
    super.initState();
    _tempFilters = List.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Filter Lawyers',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilters.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          
          // Filter Categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: _filterCategories.entries.map((entry) {
                return _FilterCategory(
                  title: entry.key,
                  options: entry.value,
                  selectedFilters: _tempFilters,
                  onFilterChanged: (filter, isSelected) {
                    setState(() {
                      if (isSelected) {
                        _tempFilters.add(filter);
                      } else {
                        _tempFilters.remove(filter);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          
          // Apply Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  widget.onFiltersChanged(_tempFilters);
                  Navigator.pop(context);
                },
                child: Text('Apply Filters (${_tempFilters.length})'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterCategory extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selectedFilters;
  final Function(String, bool) onFilterChanged;

  const _FilterCategory({
    required this.title,
    required this.options,
    required this.selectedFilters,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedFilters.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) => onFilterChanged(option, selected),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Placeholder for Lawyer Detail Screen
class LawyerDetailScreen extends StatelessWidget {
  final LawyerProfile lawyer;

  const LawyerDetailScreen({super.key, required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lawyer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lawyer.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lawyer.specialization,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${lawyer.experience} years experience',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Bio
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lawyer.bio,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // Achievements
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...lawyer.achievements.map((achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(achievement),
                ],
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Message'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Book Consultation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Model
class LawyerProfile {
  final String id;
  final String name;
  final String specialization;
  final int experience;
  final double rating;
  final int reviewCount;
  final String location;
  final String fees;
  final String imageUrl;
  final String bio;
  final List<String> achievements;

  LawyerProfile({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.fees,
    required this.imageUrl,
    required this.bio,
    required this.achievements,
  });
}
